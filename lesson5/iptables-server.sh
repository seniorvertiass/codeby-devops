#!/bin/bash
sudo iptables -A INPUT -p icmp -j DROP
sudo iptables -A INPUT -p tcp --dport 22 -s 172.28.96.177 -j ACCEPT
sudo netfilter-persistent save
