class ceph {
  class { "ceph-base": }
}

class ceph-packages {
  class { "ceph-packages-base": }
}

class ceph-osd {
  class { "ceph-osd-base": }
}

class ceph-mds {
  class { "ceph-mds-base": }
}

