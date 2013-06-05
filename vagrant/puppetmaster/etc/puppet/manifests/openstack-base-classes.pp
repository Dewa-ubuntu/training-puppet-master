class openstack-base ( $release = "grizzly" ) {
  class { 'openstack-package-base':
    release => "$release";
  }
}

class openstack-package-base ( $release = "grizzly" ) {
  case "$lsbdistid" {
    "Debian","Ubuntu": {
      apt::source { "ubuntu-cloud-archive":
        location          => "http://ubuntu-cloud.archive.canonical.com/ubuntu",
        release           => "${lsbdistcodename}-updates/${release}",
        repos             => "main",
        required_packages => 'ubuntu-cloud-keyring',
        include_src       => false
      }
    }
  }
}

class nova-config ( $database_host = 'alice', $rabbit_host ='alice', $glance_api_host = 'alice' ) {
  class { 'nova':
    nova_cluster_id => 'localzone',
    sql_connection  => "mysql://novadbadmin:dieD9Mie@${database_host}/nova",
    glance_api_servers => "$glance_api_host:9292",
    rabbit_host     => $rabbit_host,
    rabbit_password => 'guest',
    rabbit_userid   => 'guest',
    auth_strategy   => 'keystone',
    verbose         => true,
    debug           => true,
  }
}

class quantum-config ( $rabbit_host = 'alice' ) {
  class { 'quantum':
    allow_overlapping_ips => false,
    rabbit_host           => $rabbit_host,
    rabbit_password       => 'guest',
    debug                 => true,
    verbose               => true,
  }
}
  
class cloud-controller-base ($amqp_server = "rabbitmq",  $database = "mysql" ) inherits openstack-base {

  case "$amqp_server" {
    'rabbitmq': {
      package { "rabbitmq-server":
        ensure => installed;
      }
    }
  }

  case "$database" {
    'mysql': {
      class { 'mysql::server':
        config_hash => {
          'root_password' => 'hastexo',
          'restart' => true
        }
      }
      class { 'mysql::python': }
      file { '/etc/mysql/conf.d/mysqld-bind-address.cnf':
        source => "puppet:///public/etc/mysql/conf.d/mysqld-bind-address.cnf",
        ensure => 'present'
      }
      file { '/etc/mysql/conf.d/mysqld-skip-name-resolve.cnf':
        source => "puppet:///public/etc/mysql/conf.d/mysqld-skip-name-resolve.cnf",
        ensure => 'present'
      }

      class { 'nova::db::mysql':
        user          => 'novadbadmin',
        password      => 'dieD9Mie',
        host          => $hostname,
        charset       => 'utf8',
        allowed_hosts => '%',
        cluster_id    => 'localzone'
      }

      class { 'glance::db::mysql':
        user          => 'glancedbadmin' ,
        password      => 'ohC3teiv',
        dbname        => 'glance',
        allowed_hosts => '%',
      }

      class { 'keystone::db::mysql':
        dbname   => 'keystone',
        user     => 'keystonedbadmin',
        password => 'Ue0Ud7ra',
        host     => '%',
        charset => 'utf8';
      }

      mysql::db { 'quantum':
        user     => 'quantumdbadmin',
        password => 'wozohB8g',
        host     => '%',
        grant    => ['all'],
        charset => 'utf8';
      }

      class { 'cinder::db::mysql':
        dbname        => 'cinder',
        user          => 'cinderdbadmin',
        password      => 'ceeShi4O',
        allowed_hosts => '%',
        charset       => 'utf8',
        cluster_id    => 'localzone';
      }
    }
  }

  class { 'glance::registry':
    require           => Class['glance::db::mysql'],
    verbose           => True,
    debug             => True,
    auth_type         => 'keystone',
    auth_port         => '35357',
    auth_host         => $keystone_host,
    keystone_tenant   => 'services',
    keystone_user     => 'glance',
    keystone_password => 'hastexo',
    sql_connection    => "mysql://glancedbadmin:ohC3teiv@${hostname}/glance",
    enabled           => $enabled,
  }

  class { 'nova-config':
    rabbit_host => $rabbit_host,
    database_host => $database_host,
    glance_api_host => $glance_api_host,
    require          => Class['nova::db::mysql'];
  }

  class { 'nova::scheduler':
    enabled          => true,
    require          => Class['nova-config'];    
  }

  class { 'nova::conductor':
    enabled          => true,
    require          => Class['nova-config'];
  }

  class { 'nova::cert':
    enabled          => true,
    require          => Class['nova-config'];
  }

  class { 'nova::consoleauth':
    enabled          => true,
    require          => Class['nova-config'];

  }
  
  class { 'nova::objectstore':
    enabled          => true,
    require          => Class['nova-config'];
  }
  
}

class storage-controller-base
  ( $cinder_driver = 'iscsi',
    $cinder_lvm_pv = '/dev/vdb',
    $rabbit_host = 'alice',
    $database_host = 'alice',
    $keystone_host = 'alice',
    $cinder_ip_address = $ipaddress_eth1,
    $cinder_iscsi_ip_address = $ipaddress_eth1 ) inherits openstack-base  {

  class { cinder:
    rabbit_host     => $rabbit_host,
    rabbit_password => 'guest',
    sql_connection  => "mysql://cinderdbadmin:ceeShi4O@${database_host}/cinder";
  }

  class { 'cinder::api':
    require                => Class['cinder::keystone::auth'],
    keystone_password      => 'hastexo',
    keystone_enabled       => true,
    keystone_tenant        => 'services',
    keystone_user          => 'cinder',
    keystone_auth_host     => $keystone_host,
    keystone_auth_port     => '35357',
    keystone_auth_protocol => 'http',
    service_port           => '5000',
    package_ensure         => 'latest',
    bind_host              => '0.0.0.0',
    enabled                => true,
  }

  class { 'cinder::scheduler': }

  case "$cinder_driver" {
    "iscsi": {
      physical_volume { $cinder_lvm_pv:
        ensure => present;
      }
      volume_group { "cinder-volumes":
        ensure => present,
        physical_volumes => "$cinder_lvm_pv";
      }

      class { 'cinder::volume': }

      class { 'cinder::volume::iscsi':
        require          => Volume_Group['cinder-volumes'],
        iscsi_ip_address => "$cinder_iscsi_ip_address",
        volume_group     => 'cinder-volumes',
        iscsi_helper     => 'tgtadm';
      }
    }
  }
}

class compute-node-base (
  $nova_driver = 'libvirt',
  $hypervisor = 'kvm',
  $cinder_driver = 'iscsi',
  $database_host = "alice",
  $rabbit_host = "alice",
  $glance_api_host = "alice",
  $quantum_host = "alice" ) inherits openstack-base {

  class { 'nova-config':
    rabbit_host => $rabbit_host,
    database_host => $database_host,
    glance_api_host => $glance_api_host
  }

  class { 'nova::compute':
    enabled                       => true,
    vnc_enabled                   => true,
    vncserver_proxyclient_address => '127.0.0.1',
    virtio_nic                    => true,
    require                       => Class['nova-config']
 }
  
  class { 'nova::compute::libvirt':
    libvirt_type => $hypervisor,
  }

  class { 'nova::network::quantum':
    quantum_admin_password    => 'hastexo',
    quantum_auth_strategy     => 'keystone',
    quantum_url               => "http://${quantum_host}:9696",
    quantum_admin_tenant_name => 'services',
    quantum_region_name       => 'RegionOne',
    quantum_admin_username    => 'quantum',
    quantum_admin_auth_url    => "http://${quantum_host}:35357/v2.0",
    security_group_api        => 'quantum',
  }

  class { quantum-config:
    rabbit_host           => $rabbit_host,
  }

  class { 'quantum::agents::ovs':
    integration_bridge => 'br-int',
    enable_tunneling   => true,
    local_ip           => $local_tunnel_ip,
    tunnel_bridge      => 'br-tun';
  }

  case "$cinder_driver" {
    "iscsi": {
      package { "open-iscsi":
        ensure => installed;
      }
      package { "open-iscsi-utils":
        ensure => installed;
      }
    }
  }
}


class api-node-base ( $database_host = "alice", $keystone_host = "alice", $rabbit_host = "alice" ) inherits openstack-base {

  class { 'keystone':
    admin_token => 'hastexo',
    sql_connection => "mysql://keystonedbadmin:Ue0Ud7ra@${database_host}/keystone",
    verbose     => true,
    debug       => true;
  }

  class { 'keystone::endpoint':
    public_address   => $keystone_host,
    admin_address    => $keystone_host,
    internal_address => $keystone_host,
    region           => 'RegionOne',
    require          => Class['keystone'];
  }

  class { 'keystone::roles::admin':
    email        => 'admin@example.com',
    password     => 'hastexo',
    admin_tenant => 'admin',
    require => Class['keystone::endpoint'];
  }

  class { 'glance::api':
    require           => Class['keystone::roles::admin'],
    verbose           => True,
    debug             => True,
    auth_type         => 'keystone',
    auth_port         => '35357',
    auth_host         => $keystone_host,
    keystone_tenant   => 'services',
    keystone_user     => 'glance',
    keystone_password => 'hastexo',
    sql_connection    => "mysql://glancedbadmin:ohC3teiv@${database_host}/glance",
    enabled           => $enabled,
  }

  class { 'glance::keystone::auth':
    require           => Class['keystone::roles::admin'],
    password         => 'hastexo',
    public_address   => $hostname,
    admin_address    => $hostname,
    internal_address => $hostname,
    region           => 'RegionOne',
  }

  class { 'glance::backend::file':
  }

  class { quantum-config:
    rabbit_host           => $rabbit_host,
  }

  class { 'quantum::server':
    auth_type      => 'keystone',
    auth_host      => $keystone_host,
    auth_port      => '35357',
    auth_tenant    => 'services',
    auth_user      => 'quantum',
    auth_password  => 'hastexo',
    auth_protocol  => 'http',
  }


  class { 'quantum::keystone::auth':
    require            => Class['keystone::roles::admin'],
    password           => 'hastexo',
    auth_name          => 'quantum',
    email              => 'quantum@localhost',
    tenant             => 'services',
    configure_endpoint => true,
    service_type       => 'network',
    public_protocol    => 'http',
    public_address     => $hostname,
    admin_address      => $hostname,
    internal_address   => $hostname,
    region             => 'RegionOne'
  }

  class { 'quantum::plugins::ovs':
    sql_connection       => "mysql://quantumdbadmin:wozohB8g@${database_host}/quantum",
    tenant_network_type  => 'gre',
    tunnel_id_ranges     => '1:1000',
    network_vlan_ranges  => '';
  }


  class { 'nova::api':
    admin_user     => 'nova',
    admin_password => 'hastexo',
    enabled        => true,
    auth_strategy  => 'keystone',
    auth_host      => $keystone_host,
    admin_tenant_name => 'services',
    api_bind_address => '0.0.0.0',
    metadata_listen  => '0.0.0.0',
    enabled_apis     => 'ec2,osapi_compute,metadata',
    volume_api_class => 'nova.volume.cinder.API';
  }

  class { 'nova::keystone::auth':
    require          => Class['keystone::roles::admin'],
    password         => 'hastexo',
    auth_name        => 'nova',
    public_address   => $hostname,
    admin_address    => $hostname,
    internal_address => $hostname,
    compute_port     => '8774',
    volume_port      => '8776',
    ec2_port         => '8773',
    compute_version  => 'v2',
    volume_version   => 'v1',
    region           => 'RegionOne',
    tenant           => 'services',
    email            => 'nova@localhost',
    cinder           => true,
    public_protocol  => 'http'
  }

#  class { cinder:
#    rabbit_host     => $rabbit_host,
#    rabbit_password => 'guest',
#    sql_connection  => "mysql://cinderdbadmin:ceeShi4O@${database_host}/cinder";
#  }

  class { 'cinder::keystone::auth':
    require            => Class['keystone::roles::admin'],
    password           => 'hastexo',
    auth_name          => 'cinder',
    email              => 'cinder@localhost',
    tenant             => 'services',
    configure_endpoint => true,
    service_type       => 'volume',
    public_address     => $hostname,
    admin_address      => $hostname,
    internal_address   => $hostname,
    port               => '8776',
    volume_version     => 'v1',
    region             => 'RegionOne',
    public_protocol    => 'http'
  }

}

class dashboard-node-base ( $keystone_host = 'alice', $database_host = 'alice' ) inherits openstack-base {

  package { 'memcached':
    ensure => installed;
  }

  class { 'horizon':
    require               => Package['memcached'],
    secret_key            => 'hastexo',
    cache_server_ip       => '127.0.0.1',
    cache_server_port     => '11211',
    swift                 => false,
    quantum               => true,
    keystone_host         => "$keystone_host",
    keystone_default_role => 'Member',
    django_debug          => 'True',
    api_result_limit      => 1000,
    log_level             => 'DEBUG',
    can_set_mount_point   => 'True',
    listen_ssl            => 'False';
  }


}

class network-node-base ( $local_tunnel_ip, $rabbit_host = 'alice', $keystone_host = 'alice', $metadata_ip = '192.168.122.111' ) inherits openstack-base {

  file { 'sysctl-forward':
    path    => '/etc/sysctl.d/60-ip_forward.conf',
    content => 'net.ipv4.ip_forward = 1',
  }

  class { quantum-config:
    rabbit_host           => $rabbit_host,
  }

  class { 'quantum::agents::ovs':
    bridge_mappings    => ['eth3:br-ex'],
    bridge_uplinks     => ['br-ex:eth3'],
    integration_bridge => 'br-int',
    enable_tunneling   => true,
    local_ip           => $local_tunnel_ip,
    tunnel_bridge      => 'br-tun',
    polling_interval   => 2,
    root_helper        => 'sudo /usr/bin/quantum-rootwrap /etc/quantum/rootwrap.conf'
  }

  class { 'quantum::agents::dhcp':
    debug           => 'True',
    use_namespaces  => 'False';
  }

  class { 'quantum::agents::l3':
    debug                        => 'True',
    auth_tenant                  => 'services',
    auth_user                    => 'quantum',
    auth_password                => 'hastexo',
    external_network_bridge      => 'br-ex',
    use_namespaces               => 'False',
    router_id                    => 'a2470c0d-be29-4874-82fd-d52d6369f880',
    gateway_external_network_id  => '641786c9-1fe1-49c1-bcee-8a0d27a3b2fc',
    metadata_ip                  => '127.0.0.1';
  }

  class { 'quantum::agents::metadata':
    debug                        => 'True',
    auth_tenant                  => 'services',
    auth_user                    => 'quantum',
    auth_password                => 'hastexo',
    shared_secret                => 'hastexo',
    auth_url                     => "http://${keystone_host}:35357/v2.0",
    auth_region                  => 'RegionOne',
    metadata_ip                  => $metadata_ip;
  }

}

class swift-base ( $swift_local_net_ip, $swift_replicas = 3 )
  inherits openstack-base {

  package { 'memcached':
    ensure => installed;
  }

  class { 'swift':
    require           => Package['memcached'],
    swift_hash_suffix => 'hastexo',
    package_ensure    => latest;
  }
}


class swift-proxy-base ( $swift_local_net_ip, $swift_replicas = 3 )
  inherits swift-base {

  class { 'swift::proxy':
    proxy_local_net_ip => $swift_local_net_ip,
    pipeline           => ['healthcheck', 'cache', 'tempauth', 'proxy-server'],
    account_autocreate => true,
    require            => Class['swift::ringbuilder'],
  }

  class { ['swift::proxy::healthcheck',
           'swift::proxy::cache',
           'swift::proxy::tempauth']: }
}

class swift-ringbuilder-base ( $swift_local_net_ip, $swift_replicas = 3 )
  inherits swift-base {

 class { 'swift::ringbuilder':
    part_power     => '18',
    replicas       => $swift_replicas,
    min_part_hours => 1,
    require        => Class['swift'];
  }
}

class swift-storage-node-base
  ( $swift_node_id, $swift_zone_id, $swift_local_net_ip, $swift_lvm_pv)
  inherits swift-base {

  lvm::volume { "node-$swift_node_id":
    ensure => present,
    pv     => $swift_lvm_pv,
    vg     => 'swift',
    fstype => 'xfs',
    size   => '1G'
  }

  # TODO: Mount the filesystem
  
  swift::storage::node { $swift_node_id:
    require              => Lvm::Volume["node-$swift_node_id"],
    mnt_base_dir         => '/srv/node',
    weight               => 1,
    manage_ring          => true,
    zone                 => $swift_zone_id,
    storage_local_net_ip => $swift_local_net_ip
  }
}

class client-node-base inherits openstack-base {

  package { 'python-keystoneclient':
    ensure => installed,
    require => Class['openstack-package-base'];
  }

  package { 'python-glanceclient':
    ensure => installed,
    require => Class['openstack-package-base'];
  }

  package { 'python-quantumclient':
    ensure => installed,
    require => Class['openstack-package-base'];
  }

  package { 'python-novaclient':
    ensure => installed,
    require => Class['openstack-package-base'];
  }

  package { 'python-swiftclient':
    ensure => installed,
    require => Class['openstack-package-base'];
  }
}
