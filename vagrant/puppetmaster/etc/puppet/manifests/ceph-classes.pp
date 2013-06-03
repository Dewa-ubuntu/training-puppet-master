class ceph {
  class { "ceph-base":
    release => $::ceph_release,
  }
}

class radosgw {
  class { "radosgw-base": }
}

class ceph-osd {
  class { "ceph-osd-base": }
}
