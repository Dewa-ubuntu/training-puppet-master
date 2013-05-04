# /etc/puppet/manifests/nodes.pp

node alice {
  class { "ceph": }
  class { "ceph-packages": }
}

node bob {
  class { "ceph": }
  class { "ceph-packages": }
  class { "ceph-openstack": }
  class { 'openstack::controller':
  require                 => Class['ceph'],
  public_address          => '192.168.122.112',
  public_interface        => 'eth1',
  private_interface       => 'eth2',
  internal_address        => '192.168.133.112',
  floating_range          => '192.168.101.64/28',
  fixed_range             => '10.0.0.0/24',
  multi_host              => false,
  network_manager         => 'nova.network.manager.FlatDHCPManager',
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
  }
}

node charlie {
  class { "ceph": }
  class { "ceph-packages": }
  class { "ceph-osd": }
}

node daisy {
  class { "ceph": }
  class { "ceph-packages": }
  class { "ceph-osd": }
  class { "ceph-radosgw": }
  class { "ceph-deploy": }
}

node eric {
  class { "ceph": }
  class { "ceph-packages": }
  class { "ceph-osd": }
}

node frank {
  class { "ceph": }
  class { "ceph-packages": }
  class { "ceph-osd": }
}
