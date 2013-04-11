# /etc/puppet/manifests/nodes.pp

node alice {
  class { "ceph": }
  class { "ceph-packages": }
}

node daisy {
  class { "ceph": }
  class { "ceph-packages": }
  class { "ceph-osd": }
  class { "ceph-radosgw": }
}

node eric {
  class { "ceph": }
  class { "ceph-packages": }
  class { "ceph-osd": }
  class { "ceph-radosgw": }
}

node frank {
  class { "ceph": }
  class { "ceph-packages": }
  class { "ceph-osd": }
  class { "ceph-radosgw": }
}
