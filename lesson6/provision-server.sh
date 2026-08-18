#!/bin/bash

set -e

echo "=== Provisioning SERVER ==="

apt-get update
apt-get install -y openssh-server

systemctl enable ssh
systemctl start ssh


mkdir -p /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh

if [ -f /vagrant/keys/client_to_server.pub ]; then
    cat /vagrant/keys/client_to_server.pub >> /home/vagrant/.ssh/authorized_keys
fi

chmod 600 /home/vagrant/.ssh/authorized_keys

chown -R vagrant:vagrant /home/vagrant/.ssh


echo "=== SERVER ready ==="
