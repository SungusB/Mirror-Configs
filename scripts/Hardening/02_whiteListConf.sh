#!bin/bash

set -e

whiteListFile="/etc/crowdsec/parsers/s02-enrich/00-unicamp-whitelist.yaml"

echo " (1)Generating whitelist file in $whiteListFile"

cat <<YAML | tee $whiteListFile
name: unicamp/mirror-whitelist
description: "Whitelist funcoes mirror"
whitelist:
  reason: "Infra definition for crowdsec"
  ip:
    - "127.0.0.1"
    - "::1"
    - "201.71.62.115"
    - "201.68.181.67"
    - "172.23.0.3"
    - "172.23.0.4"
  cidr:
    - "100.64.0.0/10"
    - "172.16.0.0/12"
    - "143.106.0.0/16"
YAML

echo "procedure complete"
