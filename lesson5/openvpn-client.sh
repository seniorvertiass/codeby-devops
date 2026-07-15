#!/bin/bash
sudo apt-get update
sudo apt-get install openvpn -y

sudo tee /etc/openvpn/client.conf << EOF
client
dev tun
proto udp
remote 172.28.96.177 1194
resolv-retry infinite
nobind
persist-key
persist-tun
ca ca.crt
cert client1.crt
key client1.key
tls-auth ta.key 1
cipher AES-256-CBC
verb 3
EOF


sudo systemctl start openvpn@client


