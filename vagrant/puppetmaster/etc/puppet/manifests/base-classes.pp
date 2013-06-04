class hastexo-base {

  class { 'apt':
    proxy_host           => training-puppet-master,
    proxy_port           => '3128',
    purge_sources_list   => true,
  }

  apt::source { "precise":
      location          => "http://us.archive.ubuntu.com/ubuntu/",
      release           => "precise",
      repos             => "main restricted",
      include_src       => true
  }

  apt::source { "precise-updates":
      location          => "http://us.archive.ubuntu.com/ubuntu/",
      release           => "precise-updates",
      repos             => "main restricted",
      include_src       => true 
  }

  apt::source { "precise-universe":
      location          => "http://us.archive.ubuntu.com/ubuntu/",
      release           => "precise",
      repos             => "universe",
      include_src       => true 
  }

  apt::source { "precise-universe-updates":
      location          => "http://us.archive.ubuntu.com/ubuntu/",
      release           => "precise-updates",
      repos             => "universe",
      include_src       => true
  }

  apt::source { "precise-multiverse":
      location          => "http://us.archive.ubuntu.com/ubuntu/",
      release           => "precise",
      repos             => "multiverse",
      include_src       => true
  }

  apt::source { "precise-multiverse-updates":
      location          => "http://us.archive.ubuntu.com/ubuntu/",
      release           => "precise-updates",
      repos             => "multiverse",
      include_src       => true
  }

  apt::source { "precise-backports":
      location          => "http://us.archive.ubuntu.com/ubuntu/",
      release           => "precise-backports",
      repos             => "main restricted universe multiverse",
      include_src       => true
  }

  apt::source { "precise-security":
      location          => "http://security.ubuntu.com/ubuntu",
      release           => "precise-security",
      repos             => "main restricted universe multiverse",
      include_src       => true
  }

  apt::source { "precise-cloud-archive":
      location          => "http://ubuntu-cloud.archive.canonical.com/ubuntu",
      release           => "precise-updates/grizzly",
      repos             => "main",
      key               => "5EDB1B62EC4926EA",
      key_server        => "keyserver.ubuntu.com",
      include_src       => true,
  }

  apt::source { "ceph-bobtail":
      location          => "http://ceph.com/debian-bobtail",
      release           => "precise",
      repos             => "main",
      key               => "17ED316D",
      key_server        => "pgp.mit.edu",
      include_src       => false,
  }
}

class packages-base {

  class { "ntp": }

  package { "console-data":
    ensure => "installed",
    require  => Class['hastexo-base'],
  }
  package { "screen":
    ensure => "installed",
    require  => Class['hastexo-base'],
  }
  package { "vim":
    ensure => "installed",
    require  => Class['hastexo-base'],  
  }
  package { "less":
    ensure => "installed",
    require  => Class['hastexo-base'],
  }
  package { "wget":
    ensure => "installed",
    require  => Class['hastexo-base'],
  }
  package { "curl":
    ensure => "installed",
    require  => Class['hastexo-base'],
  }
  package { "nano":
    ensure => "installed",
    require  => Class['hastexo-base'],
  }
  package { "rsync":
    ensure => "installed",
    require  => Class['hastexo-base'],
  }
}

class mysql-for-puppet-dashboard-base {
  class { 'mysql::server':
    config_hash => { 'root_password' => 'hastexo' },
    require  => Class['hastexo-base'],
  }

  mysql::db { 'dashboard_production':
    user     => 'dashboard',
    password => 'seecaW4yau',
    host     => 'localhost',
    grant    => ['all'],
    charset => 'utf8',
    require  => Class['hastexo-base'],
  }

  package { "libmysqlclient-dev":
    ensure => "installed",
    require  => Class['hastexo-base'],
  }
}

class puppet-dashboard-base {
  package { "puppet-dashboard":
    ensure => "installed",
    require  => Class['mysql-for-puppet-dashboard-base'],
  }

  package { "apache2":
    ensure => "installed",
    require  => Class['mysql-for-puppet-dashboard-base'],
  }

  service { "apache2":
    ensure  => "running",
    enable  => "true",
    require => Package["apache2"],
  }

  exec { 'gem install rails -v 2.3.12 --no-ri --no-rdoc':
    path => ['/usr/bin', '/usr/sbin'],
    require => Class['mysql-for-puppet-dashboard-base'],
  }

  exec { 'gem install mysql --no-ri --no-rdoc':
    path => ['/usr/bin', '/usr/sbin'],
    require => Class['mysql-for-puppet-dashboard-base'],
  }

  file { "/etc/puppet-dashboard/database.yml":
    source => "puppet:///public/etc/puppet-dashboard/database.yml",
    ensure => 'present',
    group => 'www-data',
    require => Package['puppet-dashboard'];
  }

  file { "/etc/puppet-dashboard/settings.yml":
    source => "puppet:///public/etc/puppet-dashboard/settings.yml",
    ensure => 'present',
    group => 'www-data',
    require => Package['puppet-dashboard'];
  }

  exec { 'rake RAILS_ENV=production db:migrate':
    cwd => '/usr/share/puppet-dashboard',
    path => ['/usr/bin', '/usr/sbin'],
    require => [ Package['puppet-dashboard'],
                 File["/etc/puppet-dashboard/settings.yml", "/etc/puppet-dashboard/database.yml"],
                 Mysql::Db["dashboard_production"] ]
  }

  file { "/etc/apache2/mods-available/passenger.conf":
    source => "puppet:///public/etc/apache2/mods-available/passenger.conf",
    ensure => 'present',
    owner => root,
    group => 'root',
    notify => Service['apache2'],
    require => Package['puppet-dashboard'];
  }

  file { "/etc/apache2/sites-available/puppet-dashboard":
    source => "puppet:///public/etc/apache2/sites-available/puppet-dashboard",
    ensure => 'present',
    owner => root,
    group => 'root',
    notify => Service['apache2'],
    require => Package['puppet-dashboard'];
  }

  file { "/etc/apache2/sites-available/puppetmaster":
    source => "puppet:///public/etc/apache2/sites-available/puppetmaster",
    ensure => 'present',
    owner => root,
    group => 'root',
    notify => Service['apache2'],
    require => Package['puppet-dashboard'];
  }

  exec { 'a2ensite puppet-dashboard':
    path => ['/usr/bin', '/usr/sbin'],
    notify => Service['apache2'],
    require => [ File["/etc/apache2/sites-available/puppet-dashboard"] ]
  }

  exec { 'update-rc.d -f puppet-dashboard remove':
    path => ['/usr/bin', '/usr/sbin'],
    require => [ File["/etc/apache2/sites-available/puppet-dashboard"] ]
  }

  exec { 'update-rc.d -f puppet-dashboard-workers remove':
    path => ['/usr/bin', '/usr/sbin'],
    require => [ File["/etc/apache2/sites-available/puppet-dashboard"] ]
  }
}

class puppet-dashboard-workers-base {
  exec { 'update-rc.d puppet-dashboard-workers start 92 2 3 4 5 . stop 08 0 1 6 .':
    path => ['/usr/bin', '/usr/sbin'],
    require => Class['puppet-dashboard-base'],
  }

  file { "/etc/default/puppet-dashboard-workers":
    source => "puppet:///public/etc/default/puppet-dashboard-workers",
    ensure => 'present',
    owner => root,
    group => 'root',
    notify => Service['puppet-dashboard-workers'],
    require => Class['puppet-dashboard-base'],
  }

  service { "puppet-dashboard-workers":
    ensure  => "running",
    provider  => "init",
    require => [ File["/etc/default/puppet-dashboard-workers"] ]
  }

  exec { 'chown -R puppet:puppet /var/lib/puppet':
    path => ['/bin', '/usr/bin', '/usr/sbin'],
    require => [ File["/etc/default/puppet-dashboard-workers"] ],
  }

}
