define apache::loadmodule () {

    package { "libapache2-mod-$name":
        ensure => installed
    }

    exec { "/usr/sbin/a2enmod $name" :
        unless => "/bin/readlink -e /etc/apache2/mods-enabled/${name}.load",
        notify => Service[apache2]
    }
}

define apache::loadsite () {

    exec { "/usr/sbin/a2ensite $name" :
        unless => "/bin/readlink -e /etc/apache2/sites-enabled/${name}",
        notify => Service[apache2]
    }
}
