define apache::loadmodule () {

    package { "libapache2-mod-$name":
      ensure => installed,
      require => Package['apache2'];
    }

    exec { "/usr/sbin/a2enmod $name" :
      unless => "/bin/readlink -e /etc/apache2/mods-enabled/${name}.load",
      notify => Service[apache2],
      require => Package["libapache2-mod-$name"];
    }
}

define apache::loadsite () {

    exec { "/usr/sbin/a2ensite $name" :
      unless => "/bin/readlink -e /etc/apache2/sites-enabled/${name}",
      notify => Service[apache2],
      require => Package['apache2'];
    }
}
