#!/bin/bash

if [ -e "/vagrant/provisioned" ]; then
  echo "Node already provisioned."
  exit 0
fi

PROXY_HOST="10.0.2.2"

TEMP=`getopt -o n:p: --long hostname:,proxy:  -- "$@"`

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

eval set -- "$TEMP"

while true ; do
    case "$1" in
	-n|--hostname)
	    HOSTNAME=$2 
	    shift 2
	    ;;
	-p|--proxy)
	    PROXY_HOST=$2
	    shift 2
	    ;;
	--) 
	    shift
	    break
	    ;;
    esac
done

if [ -z "$HOSTNAME" ]; then
    echo "Hostname not set" >2
    exit 1
fi

cat >> /etc/hosts <<EOF

# added by $0
192.168.122.5 training-puppet-master

192.168.122.111 alice
192.168.122.112 bob
192.168.122.113 charlie
192.168.122.114 daisy
192.168.122.115 eric
192.168.122.116 frank
EOF

cat >> /etc/resolv.conf <<EOF

# added by $0
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

PROXY="http://${PROXY_HOST}:3128"
export http_proxy="$PROXY"
export ftp_proxy="$PROXY"
export https_proxy="$PROXY"
export no_proxy="localhost,127.0.0.1,$HOSTNAME"

cat >> /etc/environment <<EOF

# added by $0
http_proxy="$http_proxy"
ftp_proxy="$ftp_proxy"
https_proxy="$https_proxy"
no_proxy="$no_proxy"
EOF

wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb
dpkg -i puppetlabs-release-precise.deb
apt-get update

apt-get -y install puppet

sudo cp -a /vagrant/.ssh /root/
sudo chown -R root:root /root/.ssh
sudo chmod 700 /root/.ssh
sudo chmod 600 /root/.ssh/id_rsa
sudo chmod 644 /root/.ssh/id_rsa.pub
sudo chmod 600 /root/.ssh/authorized_keys2
sudo cp -a /vagrant/puppet /etc/
sudo chown -R root:root /etc/puppet

puppet agent --certname $HOSTNAME --server training-puppet-master --detailed-exitcodes --runinterval 30

# Only run these provisioning steps on the first "vagrant up"
touch /vagrant/provisioned
