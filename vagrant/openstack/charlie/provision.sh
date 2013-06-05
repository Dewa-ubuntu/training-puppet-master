#!/bin/bash
echo "192.168.122.5 training-puppet-master" >> /etc/hosts
echo "192.168.122.111 alice" >> /etc/hosts
echo "192.168.122.112 bob" >> /etc/hosts
echo "192.168.122.113 charlie" >> /etc/hosts
echo "192.168.122.114 daisy" >> /etc/hosts
echo "192.168.122.115 eric" >> /etc/hosts
echo "192.168.122.116 frank" >> /etc/hosts

#echo "http_proxy=\"http://training-puppet-master:3128/\"" >> /etc/environment
#echo "ftp_proxy=\"http://training-puppet-master:3128/\"" >> /etc/environment
#echo "https_proxy=\"http://training-puppet-master:3128/\"" >> /etc/environment

sudo cp -a /vagrant/.ssh /root/
sudo chown -R root:root /root/.ssh
sudo chmod 700 /root/.ssh
sudo chmod 600 /root/.ssh/id_rsa
sudo chmod 644 /root/.ssh/id_rsa.pub
sudo chmod 600 /root/.ssh/authorized_keys2
sudo cp -a /vagrant/puppet /etc/
sudo chown -R root:root /etc/puppet

sudo apt-get install puppet
