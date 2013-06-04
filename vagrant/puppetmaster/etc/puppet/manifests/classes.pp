class hastexo {
  class { "hastexo-base": }
}

class packages {
  class { "packages-base": }
}

class mysql-for-puppet-dashboard {
  class { "mysql-for-puppet-dashboard-base": }
}

class puppet-dashboard {
  class { "puppet-dashboard-base": }
}

class puppet-dashboard-workers {
  class { "puppet-dashboard-workers-base": }
}

class puppet-master-cleanup {
  class { "puppet-master-cleanup-base": }
}