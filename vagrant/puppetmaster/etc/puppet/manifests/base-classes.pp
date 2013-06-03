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

  package { "puppet-dashboard": ensure => "installed" }
  package { "rake": ensure => "installed" }

  file { "/etc/apache2/sites-available/puppet-dashboard":
    source => "puppet:///private/etc/apache2/sites-available/puppet-dashboard",
    ensure => 'present',
    require => Package['apache2'],
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
}

class puppetmaster-base inherits puppetlabs-base {
  package { "puppetmaster": ensure => "installed" }


  file { "/etc/apache2/sites-available/puppetmaster":
    source => "puppet:///private/etc/apache2/sites-available/puppetmaster",
    ensure => 'present',
    notify => Service['apache2']
  }

  file { "/etc/puppet/puppet.conf":
    source => "puppet:///private/etc/puppet/puppet.conf",
    ensure => 'present'
  }

  file { "/etc/puppet/auth.conf":
    source => "puppet:///private/etc/puppet/auth.conf",
    ensure => 'present'
  }

  apache::loadsite { "puppetmaster": }

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

  case "$lsbdistid" {
    "Debian": { class { "debian": } }
    "Ubuntu": { class { "ubuntu": } }
    "SUSE LINUX": {
      case "$lsbdistdescription" {
        "openSUSE.*": { class { "opensuse": } }
        ".*Enterprise Server.*": { class { "sles": }  }
      }
    }
    "CentOS": { class { "centos": } }
  }

  class { "ntp":
    ensure     => running,
    servers    => [ "0.pool.ntp.org iburst",
                    "1.pool.ntp.org iburst",
                    "2.pool.ntp.org iburst",
                    "pool.ntp.org iburst" ],
    autoupdate => true
  }

  package { "lsb-release": ensure => "installed" }
  package { "console-data": ensure => "installed" }
  package { "screen": ensure => "installed" }
  package { "vim": ensure => "installed" }
  package { "less": ensure => "installed" }

}

class apache2-base {
  package { "apache2":
    ensure => "installed"
  }

  service { "apache2":
    ensure => "running"
  }
}
