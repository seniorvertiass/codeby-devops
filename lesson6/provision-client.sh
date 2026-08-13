#!/bin/bash

set -e

echo "=== Provisioning CLIENT ==="

apt-get update
apt-get install -y openssh-client

mkdir -p /home/vagrant/.ssh

chmod 700 /home/vagrant/.ssh


cp /vagrant/keys/client_to_server /home/vagrant/.ssh/client_to_server

chmod 600 /home/vagrant/.ssh/client_to_server

chown vagrant:vagrant /home/vagrant/.ssh/client_to_server


cat > /home/vagrant/.ssh/config <<'EOF'
Host server
    HostName 192.168.56.10
    User vagrant
    IdentityFile /home/vagrant/.ssh/client_to_server
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
EOF

chmod 600 /home/vagrant/.ssh/config

chown vagrant:vagrant /home/vagrant/.ssh/config

echo "=== CLIENT provisioning completed ==="
