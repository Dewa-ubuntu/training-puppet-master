node training-puppet-master { 
  class { "base": }
  class { "apache2": }
  class { "passenger": }
  class { "puppetmaster": }
  class { "puppet-dashboard": }
}


node default {
  class { "base": }
  class { "puppet-agent": }
}
