class ceph {
  class { "ceph-base": }
}

class ceph-packages {
  class { "ceph-packages-base": }
}

class ceph-osd {
  class { "ceph-osd-base": }
}

class ceph-radosgw {
  class { "ceph-radosgw-base": }
}

class ceph-deploy {
  class { "ceph-deploy-base": }
}

class ceph-openstack {
  class { "ceph-openstack-base": }
  class { 'openstack::all':
    public_address          => '192.168.122.112',
    public_interface        => 'eth1',
    private_interface       => 'eth2',
    internal_address        => '192.168.133.112',
    floating_range          => '192.168.101.64/28',
    fixed_range             => '10.0.0.0/24',
    network_manager         => 'nova.network.manager.FlatDHCPManager',
    libvirt_type            => 'qemu',
    admin_email             => 'admin@test.com',
    admin_password          => 'admin_password',
    secret_key              => 'secret_key',
    mysql_root_password     => 'mysql_root_password',
    keystone_admin_token    => 'keystone_admin_token',
    keystone_db_password    => 'keystone_db_password',
    glance_user_password    => 'glance_user_password',
    glance_db_password      => 'glance_db_password',
    nova_user_password      => 'nova_user_password',
    nova_db_password        => 'nova_db_password',
    rabbit_password         => 'rabbit_password',
    rabbit_user             => 'rabbit_user',                                                          
    quantum                 => false,
    purge_nova_config       => false,
  }
  Class['ceph-openstack-base'] -> Class['openstack::all']
}
