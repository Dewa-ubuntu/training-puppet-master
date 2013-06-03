class ceph-base ( $release = "bobtail" ) {

  apt::source { "ceph-$release":
      location          => "http://ceph.com/debian-$release",
      release           => "$lsbdistcodename",
      repos             => "main",
      key               => "17ED316D",
      key_server        => "pgp.mit.edu",
      include_src       => false,
  }

}

class radosgw-base inherits ceph-base {

  package { "radosgw":
    ensure => "installed",
  }

  package { "libapache2-mod-fastcgi":
    ensure => "installed",
  }

}

class ceph-osd-base inherits ceph-base {
  package { "ceph":
    ensure => "installed",
  }

  package { "xfsprogs":
    ensure => "installed",
  }
}
