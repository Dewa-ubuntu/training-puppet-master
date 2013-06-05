# classes.pp: classes, typically parameterized, that
#             describe node roles.
#
# Every role should be self-contained such
# that they can be combined at will.
# If you're writing functionality where two
# classes depend on one another, don't
# assume an admin will remember to assign
# both classes to one node. Instead, write
# a class that wraps the others.
#
# = NAMING CONVENTIONS =
# * All class names should end in -base. Wrapper classes
#   (user-facing, to be used from Dashboard) drop the
#   -base suffix.
# * Classes specific to a distribution should include
#   that distro's name in their own name.
# * Classes _without_ a distro in their name should be
#   expected to work anywhere -- where necessary, they
#   should distinguish by distro via $lsbdistid and
#   possibly $lsbdistcodename, and do the right thing
#   specific to that distribution.

# Class: debian-base
#
# Sets up the Debian software repositories.
#
# Parameters:
#   $release:
#     The Debian release to install (default "stable")
#
# Actions:
#   - Configure the debian, debian-backports, and debian-security
#     APT repositories for the configured release
#   - Remove the /etc/apt/sources_list file.
#
# Sample Usage:
# 
# class { 'debian base':
#   release   => $::debian_release
# }
class debian-base ( $release = "squeeze" ) {
  apt::source { "debian":
    location          => "http://debian.inode.at/debian",
    release           => $release,
    repos             => "main",
    required_packages => "debian-archive-keyring",
    key               => "55BE302B",
    key_server        => "pgp.mit.edu",
    include_src       => false
  }

  apt::source { "debian-security":
    location          => "http://debian.inode.at/debian-security",
    release           => "$release/updates",
    repos             => "main",
    required_packages => "debian-archive-keyring",
    include_src       => false
  }

  apt::source { "debian-backports":
    location          => "http://debian.inode.at/debian-backports",
    release           => "$release-backports",
    repos             => "main",
    required_packages => "debian-archive-keyring",
    include_src       => false
  }

  # We want everything in /etc/apt/sources.list.d, so we nuke sources.list
  file { "/etc/apt/sources.list":
    ensure => absent
  }

  exec { "/usr/bin/apt-get update":
    require => [ File['/etc/apt/sources.list'],
                 Apt::Source['debian', 'debian-security', 'debian-backports']
               ]
  }
}

class ubuntu-base ( $release = "precise" ) {
  apt::source { "precise":
      location => "http://us.archive.ubuntu.com/ubuntu/",
      release => "precise",
      repos => "main restricted",
      include_src => true
  }

  apt::source { "precise-updates":
      location => "http://us.archive.ubuntu.com/ubuntu/",
      release => "precise-updates",
      repos => "main restricted",
      include_src => true
  }

  apt::source { "precise-universe":
      location => "http://us.archive.ubuntu.com/ubuntu/",
      release => "precise",
      repos => "universe",
      include_src => true
  }

  apt::source { "precise-universe-updates":
      location => "http://us.archive.ubuntu.com/ubuntu/",
      release => "precise-updates",
      repos => "universe",
      include_src => true
  }

  apt::source { "precise-multiverse":
      location => "http://us.archive.ubuntu.com/ubuntu/",
      release => "precise",
      repos => "multiverse",
      include_src => true
  }

  apt::source { "precise-multiverse-updates":
      location => "http://us.archive.ubuntu.com/ubuntu/",
      release => "precise-updates",
      repos => "multiverse",
      include_src => true
  }

  apt::source { "precise-backports":
      location => "http://us.archive.ubuntu.com/ubuntu/",
      release => "precise-backports",
      repos => "main restricted universe multiverse",
      include_src => true
  }

  apt::source { "precise-security":
      location => "http://security.ubuntu.com/ubuntu",
      release => "precise-security",
      repos => "main restricted universe multiverse",
      include_src => true
  }

  apt::source { "precise-cloud-archive":
      location => "http://ubuntu-cloud.archive.canonical.com/ubuntu",
      release => "precise-updates/grizzly",
      repos => "main",
      key => "5EDB1B62EC4926EA",
      key_server => "keyserver.ubuntu.com",
      include_src => true,
  }

  apt::source { "ceph-bobtail":
      location => "http://ceph.com/debian-bobtail",
      release => "precise",
      repos => "main",
      key => "17ED316D",
      key_server => "pgp.mit.edu",
      include_src => false,
  }
}

# Class: percona-server-base
#
# Installs the Percona Server MySQL database.
#
# Parameters:
#   $version:
#     The Percona Server version to install (default 5.5)
#
# Actions:
#   - Configure the platform-specific repo.percona.com
#     software repository
#   - Install the percona-server-server package (and dependencies)
#
# Sample Usage:
# 
# class { 'percona-server-base':
#   version   => $::percona_server_version
# }
class percona-server-base ( $version = "5.5" ) {

  case "$lsbdistid" {
    "Debian","Ubuntu": {
      apt::source { "percona-server":
        location          => "http://repo.percona.com/apt",
        release           => "$lsbdistcodename",
        repos             => "main",
        key               => "CD2EFD2A",
        key_server        => "pgp.mit.edu",
        include_src       => false
      }
    }
  }

  package { "percona-server-server-$version":
    ensure           => installed
  }

}

class mysql-server-base {
}

class puppetlabs-base {

  case "$lsbdistid" {
    "Debian","Ubuntu": {
      apt::source { "puppetlabs":
        location          => "http://apt.puppetlabs.com/",
        release           => "$lsbdistcodename",
        repos             => "main",
        key	          => "1054B7A24BD6EC30",
        key_source        => "http://apt.puppetlabs.com/keyring.gpg",
        include_src       => false
      }
    }
  }

}

class puppet-dashboard-base inherits puppetlabs-base {

  package { "puppet-dashboard":
    ensure => "installed",
    require => Class['distro'];
  }
  
  package { "rake": ensure => "installed" }

  file { "/etc/apache2/sites-available/puppet-dashboard":
    source => "puppet:///private/etc/apache2/sites-available/puppet-dashboard",
    ensure => 'present',
    require => Package['apache2', 'puppet-dashboard'],
    notify => Service['apache2']
  }

  file { "/etc/puppet-dashboard/database.yml":
    source => "puppet:///private/etc/puppet-dashboard/database.yml",
    ensure => 'present',
    group => 'www-data',
    require => Package['puppet-dashboard'];
  }

  file { "/etc/puppet-dashboard/settings.yml":
    source => "puppet:///private/etc/puppet-dashboard/settings.yml",
    ensure => 'present',
    group => 'www-data',
    require => Package['puppet-dashboard'];
  }

  file { "/etc/default/puppet-dashboard-workers":
    source => "puppet:///private/etc/default/puppet-dashboard-workers",
    ensure => 'present',
    require => Package['puppet-dashboard'];
  }

  apache::loadsite { "puppet-dashboard":
   require => File['/etc/apache2/sites-available/puppet-dashboard'];
  }
 
  class { 'mysql::server':
    config_hash => { 'root_password' => 'hastexo' }
  }

  mysql::db { 'dashboard_production':
    user     => 'dashboard',
    password => 'seecaW4yau',
    host     => 'localhost',
    grant    => ['all'],
    charset => 'utf8',
  }

  exec { 'rake RAILS_ENV=production db:migrate':
    cwd => '/usr/share/puppet-dashboard',
    path => ['/usr/bin', '/usr/sbin'],
    require => [ Package['rake', 'puppet-dashboard'],
                 File["/etc/puppet-dashboard/settings.yml", "/etc/puppet-dashboard/database.yml"],
                 Mysql::Db["dashboard_production"] ]
  }

  service { "puppet-dashboard-workers":
    ensure => "running",
    require => [ Package['puppet-dashboard'],
                 File['/etc/default/puppet-dashboard-workers'],
                 Exec['rake RAILS_ENV=production db:migrate'] ];
  }

}

class puppetmaster-base inherits puppetlabs-base {
  package { "puppetmaster": ensure => "installed" }

  service { 'puppetmaster':
    enable => false,
    ensure => stopped;
  }

  file { "/etc/apache2/sites-available/puppetmaster":
    source => "puppet:///private/etc/apache2/sites-available/puppetmaster",
    ensure => 'present'
  }

  apache::loadsite { "puppetmaster":
    require => File['/etc/apache2/sites-available/puppetmaster']
  }

}

class puppet-agent-base inherits puppetlabs-base {
  package { "puppet": ensure => "latest" }

  file { "/etc/puppet/puppet.conf":
    source => "puppet:///public/etc/puppet/puppet.conf",
    ensure => 'present'
  }
}

class location-base {
  class { "location": }
}

class passenger-base {
  apache::loadmodule { "passenger": }
}

class base {

  # Make sure we have the lsb-release package installed
  package { "lsb-release":
    ensure => "installed"
  }

  # Then, auto-detect the distribution
  class { "distro":
    require => Package['lsb-release'];
  }

  # Install useful packages
  package { "console-data":
    ensure => installed,
    require => Class['distro'];
  }
  package { "screen":
    ensure => installed,
    require => Class['distro'];
  }
  package { "vim":
    ensure => installed,
    require => Class['distro'];
  }
  package { "less":
    ensure => installed,
    require => Class['distro'];
  }
  package { "acpid":
    ensure => installed,
    require => Class['distro'];
  }
  package { "zerofree":
    ensure => installed,
    require => Class['distro'];
  }

  # Set up and configure the NTP daemon
  class { "ntp":
    require    => Class['distro'],
    ensure     => running,
    servers    => [ "0.pool.ntp.org iburst",
                    "1.pool.ntp.org iburst",
                    "2.pool.ntp.org iburst",
                    "pool.ntp.org iburst" ],
    autoupdate => true
  }

  # Configure the hastexo user
  user { 'hastexo':
    uid        => 1001,
    shell      => '/bin/bash',
    password   => '$6$4Bx5qoBm$mbgGPndsU93ZzigANfK3qmt8YOnzXAquJpjBuzXAh0hrSa8Od.7WUM7AZAlzHEfaIB7NRWeHdb882/WRKkiq90',
    home       => '/home/hastexo',
    managehome => true,
    groups     => ['adm', 'sudo']
  }

  ssh_authorized_key { 'florian.haas@hastexo.com':
    user => 'hastexo',
    type => 'rsa',
    key => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDQYrUj6j4+ph/ZezAjXM7UutHFKs3I9SPO6v0k571tuTeY6vVfSr4KoiKD7UiP+wuculkqn3q8y2yMP2CoOhrIQDennViEbIvFlb2p9w0ScDSJGuorB3vuXuKAfbIdGte3TlcL7i3D7mu+2NqhrvnQZblsZsnWy8JnKqqp79otRlrokTSU8XhGSfjCU1I0J6rtVnZJU3RqjfvAXfWF5iplKadHBNrLTPBveGTiyEoqUEdAvuE+biSkbnGQM0dMbWMWSthhEzt8DLKbzEKUeYUo0wqScjdhEi2ySOaYznql0CFw4mWA675xTdwGtd+7lH2mhyDX5c1D6s8VEm7IUeIj',
  }
}

class apache2-base {
  package { "apache2":
    ensure => "installed",
    require => Class['distro'];
  }

  service { "apache2":
    ensure => "running",
    require => Package['apache2'];
  }
}


