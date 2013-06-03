#!/bin/bash
PROXY="http://localhost:3128"

echo "Updating /etc/hosts file..."

cat > /etc/hosts <<EOF

127.0.0.1       localhost
127.0.1.1       training-puppet-master training-puppet-master

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

# added by $0
192.168.122.111 alice
192.168.122.112 bob
192.168.122.113 charlie
192.168.122.114 daisy
192.168.122.115 eric
192.168.122.116 frank
EOF

echo "Updating /etc/resolv.conf file..."

cat > /etc/resolv.conf <<EOF

# added by $0
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

echo "Updating apt-get cache...."

apt-get update

echo "Installing squid3..."

apt-get -y install squid3

echo "Updating squid3 config..."

cat > /etc/squid3/squid.conf <<EOF
http_port 3128
http_access allow all
maximum_object_size 1024 MB
cache_replacement_policy heap LFUDA
refresh_pattern ^ftp:          1440    20%     10080
refresh_pattern ^gopher:       1440    0%      1440
refresh_pattern Packages\.bz2$ 0       20%     4320 refresh-ims
refresh_pattern Sources\.bz2$  0       20%     4320 refresh-ims
refresh_pattern Release\.gpg$  0       20%     4320 refresh-ims
refresh_pattern Release$       0       20%     4320 refresh-ims
refresh_pattern .              1440    20%     10080 override-expire override-lastmod reload-into-ims ignore-reload ignore-no-stor
EOF

echo "Restarting squid3..."

service squid3 restart

echo "Updating environment for proxy..."

cat >> /etc/environment <<EOF

# added by $0
http_proxy=$PROXY
ftp_proxy=$PROXY
https_proxy=$PROXY
EOF

source /etc/environment

echo "Updating apt-get for proxy..."

cat > /etc/apt/apt.conf.d/60proxy <<EOF
# Set by $0
Acquire {
  http {
    Proxy "$http_proxy";
    No-Cache "false";
    Max-Age "604800";     // 1 week age on index files
    No-Store "false";    // Don't Prevent the cache from storing archives
  };
};
EOF

echo "Waiting 10 seconds..."
sleep 10

echo "Downloading puppet-labs apt-repo..."

wget http://apt.puppetlabs.com/puppetlabs-release-squeeze.deb

echo "Installing puppet-labs apt-repo..."

dpkg -i puppetlabs-release-squeeze.deb

echo "Updating apt-get cache..."

apt-get update

echo "Installing puppetmaster-passenger..."

apt-get -y install puppetmaster-passenger

echo "Copying puppetmaster config and certs..."

cp -av /vagrant/var/lib/puppet /var/lib
cp -av /vagrant/etc/puppet /etc

chown -Rv puppet:puppet /var/lib/puppet /etc/puppet

echo "Restarting apache2..."

service apache2 restart

#echo "Installing puppet modules..."

#for m in \
#  puppetlabs-apt \
#  puppetlabs-mysql puppetlabs-ntp \
#  hastexo-location; do
#  puppet module install --module_repository http://forge.puppetlabs.com $m
#done

#echo "Applying puppet config..."

#puppet apply /etc/puppet/manifests/site.pp

echo "Done..."
