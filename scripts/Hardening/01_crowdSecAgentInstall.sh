#!bin/bash

set -e

echo " (1)Curling CrowdSec"
curl -s https://install.crowdsec.net | sudo bash

echo " (2)CrowdSec Agent Install (so detecta)"
apt-get update
apt-get install -y crowdsec

echo " (3)Installing collections"
cscli collections install crowdsecurity/sshd #SSH bruteforce
cscli collections install crowdsecurity/nginx #NGINX scanners/crawlers
cscli collections install crowdsecurity/linux #Privilege scal detection
cscli scenarios install crowdsecurity/iptables #TCP/UDP flood

echo " Complete Setup"
