node training-puppet-master { 
  class { "base": }
  class { "apache2": }
  class { "passenger": }
  class { "puppetmaster": }
  class { "puppet-dashboard": }
}


node default {
  class { "base": }
}

node alice {
  notify { "hey, it works.": }
  class { "ubuntu": }
  class { "openstack": }
  class { "cloud-controller": }
  class { "api-node": }
}

node bob {
  notify { "bob says hello.": }
  class { "compute-node": }
}

