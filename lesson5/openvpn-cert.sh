#!/bin/bash

cd /home/administrator/openvpn-ca
source vars

./build-key client1

mkdir -p home/administrator/client-keys
cp keys/ca.crt keys/client1.crt keys/client1.key keys/ta.key /home/administrator/client-keys/
cd /home/administrator/client-key
scp ./* administrator@172.28.96.178:/etc/openvpn/


