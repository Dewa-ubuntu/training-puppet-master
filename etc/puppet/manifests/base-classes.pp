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
  package { "radosgw":
    ensure => "installed",
    require  => Class['ceph-base'],
  }

  package { "libapache2-mod-fastcgi":
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

class ceph-fs-base {
  package { "linux-base":
    ensure => "latest",
    require => Class['ceph-base'],
    provider => "aptitude",
  }
}
