# /etc/puppet/manifests/nodes.pp

node alice {
  class { "ceph": }
  class { "ceph-packages": }
}

node bob {
  class { "ceph": }
  class { "ceph-packages": }
  class { "ceph-openstack": }
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
