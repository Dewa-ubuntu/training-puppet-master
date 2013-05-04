class ceph-base {

  class { 'apt':
    proxy_host           => training-puppet-master,
    proxy_port           => '3128',
    purge_sources_list   => true,
  }

  apt::source { "precise":
      location          => "http://us.archive.ubuntu.com/ubuntu/",
      release           => "precise",
      repos             => "main restricted",
      include_src       => true
  }

  apt::source { "precise-updates":
      location          => "http://us.archive.ubuntu.com/ubuntu/",
      release           => "precise-updates",
      repos             => "main restricted",
      include_src       => true 
  }

  apt::source { "precise-universe":
      location          => "http://us.archive.ubuntu.com/ubuntu/",
      release           => "precise",
      repos             => "universe",
      include_src       => true 
  }

  apt::source { "precise-universe-updates":
      location          => "http://us.archive.ubuntu.com/ubuntu/",
      release           => "precise-updates",
      repos             => "universe",
      include_src       => true
  }

  apt::source { "precise-multiverse":
      location          => "http://us.archive.ubuntu.com/ubuntu/",
      release           => "precise",
      repos             => "multiverse",
      include_src       => true
  }

  apt::source { "precise-multiverse-updates":
      location          => "http://us.archive.ubuntu.com/ubuntu/",
      release           => "precise-updates",
      repos             => "multiverse",
      include_src       => true
  }

  apt::source { "precise-backports":
      location          => "http://us.archive.ubuntu.com/ubuntu/",
      release           => "precise-backports",
      repos             => "main restricted universe multiverse",
      include_src       => true
  }

  apt::source { "precise-security":
      location          => "http://security.ubuntu.com/ubuntu",
      release           => "precise-security",
      repos             => "main restricted universe multiverse",
      include_src       => true
  }

  apt::source { "precise-cloud-archive":
      location          => "http://ubuntu-cloud.archive.canonical.com/ubuntu",
      release           => "precise-updates/grizzly",
      repos             => "main",
      key               => "5EDB1B62EC4926EA",
      key_server        => "keyserver.ubuntu.com",
      include_src       => true,
  }

  apt::source { "ceph-bobtail":
      location          => "http://ceph.com/debian-bobtail",
      release           => "precise",
      repos             => "main",
      key               => "17ED316D",
      key_server        => "pgp.mit.edu",
      include_src       => false,
  }
}

class ceph-packages-base {

  class { "ntp": }

  package { "console-data":
    ensure => "installed",
    require  => Class['ceph-base'],
  }
  package { "screen":
    ensure => "installed",
    require  => Class['ceph-base'],
  }
  package { "vim":
    ensure => "installed",
    require  => Class['ceph-base'],  
  }
  package { "less":
    ensure => "installed",
    require  => Class['ceph-base'],
  }
  package { "wget":
    ensure => "installed",
    require  => Class['ceph-base'],
  }
  package { "curl":
    ensure => "installed",
    require  => Class['ceph-base'],
  }
  package { "nano":
    ensure => "installed",
    require  => Class['ceph-base'],
  }
  package { "rsync":
    ensure => "installed",
    require  => Class['ceph-base'],
  }
  package { "ceph":
    ensure => "installed",
    require  => Class['ceph-base'],
  }
}

class ceph-osd-base {
  package { "xfsprogs":
    ensure => "installed",
    require  => Class['ceph-base'],
  }
}

class ceph-radosgw-base {
  package { "radosgw":
    ensure => "installed",
    require  => Class['ceph-base'],
  }

  package { "libapache2-mod-fastcgi":
    ensure => "installed",
    require  => Class['ceph-base'],
  }

  package { "apache2-mpm-prefork":
    ensure => "installed",
    require  => Class['ceph-base'],
  }
}

class ceph-deploy-base {
  package { "git-core":
    ensure => "installed", 
    require  => Class['ceph-base'],
  }
   
  package { "python-virtualenv":
    ensure => "installed",
    require  => Class['ceph-base'],
  }  
}

class ceph-openstack-base {
  package { "python-swiftclient":
    ensure => "installed",
    require  => Class['ceph-base'],
  }
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
  require                 => Class['ceph-base'],
}
}
