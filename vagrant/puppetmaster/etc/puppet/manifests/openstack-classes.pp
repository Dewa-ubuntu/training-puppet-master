class openstack {
  class { "openstack-base": 
    release => $::openstack_release,
  }
}

class cloud-controller {
  class { "cloud-controller-base":
    amqp_server => $::amqp_server,
    database => $::database;
  }
}

class storage-controller {
  class { "storage-controller-base": 
    cinder_driver => $::cinder_driver,
    cinder_lvm_pv => $::cinder_lvm_pv;
  }
}

class compute-node {
  class { "compute-node-base": 
    nova_driver => $::nova_driver,
    hypervisor => $::hypervisor,
    cinder_driver => $::cinder_driver,
  }
}

class network-node {
  class { "network-node-base":
    rabbit_host => $::rabbit_host,
    local_tunnel_ip => $::local_tunnel_ip
  }
}

class api-node {
  class { "api-node-base":
    database_host => $::database_host,
    rabbit_host => $::rabbit_host,
  }
}  

class dashboard-node {
  class { "dashboard-node-base":
    keystone_host => $::keystone_host,
  }
}

class client-node {
  class { "client-node-base": }
}

class swift-proxy {
  class { "swift-proxy-base":
    swift_local_net_ip => $::swift_local_net_ip,
    swift_replicas => $::swift_replicas;
  }
}

class swift-ringbuilder {
  class { "swift-ringbuilder-base":
    swift_local_net_ip => $::swift_local_net_ip,
    swift_replicas => $::swift_replicas;
  }
}

class swift-storage-node {
  class { "swift-storage-node-base":
    swift_local_net_ip => $::swift_local_net_ip,
    swift_replicas => $::swift_replicas,
    swift_zone_id => $::swift_zone_id,
    swift_node_id => $::swift_node_id,
  }
}
