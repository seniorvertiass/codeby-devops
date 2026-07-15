#!/bin/bash
echo 'AllowUsers administrator@172.28.96.178' | sudo tee -a /etc/ssh/sshd_config > /dev/null

