#!/bin/bash

sudo apt install openvpn easy-rsa -y

mkdir /home/administrator/openvpn-ca
cd ~/openvpn-ca


cat > vars << EOF
export KEY_COUNTRY="RU"
export KEY_PROVINCE="Test"
export KEY_CITY="Moscow"
export KEY_ORG="Codeby"
export KEY_EMAIL="admin@codeby-test.com"
export KEY_OU="Test"
export KEY_NAME="server"
EOF

source vars
./clean-all
./build-ca
./build-key-server server
./build-dh
openvpn --genkey --secret keys/ta.key


sudo cp keys/ca.crt keys/server.crt keys/server.key keys/dh2048.pem keys/ta.key /etc/openvpn/


sudo tee /etc/openvpn/server.conf << EOF
port 1194
proto udp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh2048.pem
server 10.7.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
keepalive 10 120
tls-auth ta.key 0
cipher AES-256-CBC
persist-key
persist-tun
status openvpn-status.log
verb 3
explicit-exit-notify 1
EOF

sudo sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf


sudo iptables -t nat -A POSTROUTING -s 10.7.0.0/24 -o eth0 -j MASQUERADE

sudo systemctl start openvpn@server


