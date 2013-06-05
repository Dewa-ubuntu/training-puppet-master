# wrapper-classes.pp: Wrapper classes for Puppet Dashboard.
#
# Classes defined here should NOT support
# parameters. Instead, they should read
# variables from the global scope ($::foo)
# and pass them into the classes they wrap.
# That way we can assign parameters to
# nodes (and groups) easily from the Dashboard,
# and also easily assign classes as necessary.

class percona-server {
  class { "percona-server-base": 
    version => $::percona_server_version,
  }
}

class puppetmaster {
  class { "puppetmaster-base": }
}

class puppet-dashboard {
  class { "puppet-dashboard-base": }
}

class puppet-agent {
  class { "puppet-agent-base": }
}

class ssh-server {
  class { "ssh-server-base": }
}

class distro {
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
}

class debian {
  class { "debian-base": 
    release => $::debian_release,
  }
}

class ubuntu {
  class { "ubuntu-base": 
    release => $::ubuntu_release,
  }
}

class hastexo {
  class { "hastexo-base": }
}

class passenger {
  class { "passenger-base": }
}

class apache2 {
  class { "apache2-base": }
}

