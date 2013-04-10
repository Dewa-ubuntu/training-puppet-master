# /etc/puppet/manifests/nodes.pp

node alice {
  class { "ceph": }
  class { "ceph-packages": }
  class { "ceph-osd": }
  class { "ceph-fs": }
}

node daisy {
  class { "ceph": }
  class { "ceph-packages": }
  class { "ceph-osd": }
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
