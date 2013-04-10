class ceph-base {

  class { 'apt':
    proxy_host           => training-puppet-master,
    proxy_port           => '3128',
    purge_sources_list   => true,
  }

  apt::source { "debian":
      location          => "http://http.us.debian.org/debian",
      release           => "squeeze",
      repos             => "main",
      key               => "55BE302B",
      key_server        => "pgp.mit.edu",
      include_src       => false
  }

  apt::source { "debian-updates":
      location          => "http://http.us.debian.org/debian",
      release           => "squeeze-updates",
      repos             => "main",
      include_src       => false
  }

  apt::source { "debian-security":
      location          => "http://security.debian.org/",
      release           => "squeeze/updates",
      repos             => "main",
      include_src       => false
  }

  apt::source { "debian-backports":
      location          => "http://backports.debian.org/debian-backports",
      release           => "squeeze-backports",
      repos             => "main",
      include_src       => false
  }

  apt::source { "debian-non-free":
      location          => "http://http.us.debian.org/debian",
      release           => "squeeze",
      repos             => "non-free",
      include_src       => false,
  }

  apt::source { "ceph-bobtail":
      location          => "http://ceph.com/debian-bobtail",
      release           => "squeeze",
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
  package { "nano":
    ensure => "installed",
    require  => Class['ceph-base'],
  }
  package { "rsync":
    ensure => "installed",
    require  => Class['ceph-base'],
  }
  class { "ntp":
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
