node default {
  class { "hastexo": }
  class { "packages": }
}

node training-puppet-master {
  class { "hastexo": }
  class { "packages": }
  class { "mysql-for-puppet-dashboard": }
  class { "puppet-dashboard": }
  class { "puppet-dashboard-workers": }
}