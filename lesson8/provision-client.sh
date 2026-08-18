#!/bin/bash

set -e

DOMAIN="nosyrev.local"
WWW_DOMAIN="www.nosyrev.local"
SERVER_IP="192.168.56.10"

echo "=== Configuring /etc/hosts ==="

if ! grep -q "$DOMAIN" /etc/hosts; then
    echo "$SERVER_IP $DOMAIN $WWW_DOMAIN" >> /etc/hosts
fi

echo "=== Waiting for certificate ==="

for i in {1..30}; do
    if [ -f "/vagrant/certs/$DOMAIN.crt" ]; then
        break
    fi

    sleep 2
done

if [ ! -f "/vagrant/certs/$DOMAIN.crt" ]; then
    echo "ERROR: certificate not found"
    exit 1
fi

echo "=== Installing trusted certificate ==="

cp /vagrant/certs/$DOMAIN.crt \
   /usr/local/share/ca-certificates/$DOMAIN.crt

update-ca-certificates

echo "=== CLIENT provisioning completed ==="
