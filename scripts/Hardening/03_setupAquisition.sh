#!/bin/bash
set -e

aquisFile = "/etc/crowdsec/acquis.yaml"

echo " (1)Backing up original acquisition config"
cp $aquisFile "$aquisFile.bak.$(date +%F)" 2>/dev/null || true

echo " (2)Writing new Acquisition config"
cat <<YAML | tee $aquisFile

# SSH Logs
filenames:
  - /var/log/auth.log
labels:
  type: syslog
---
# 2. Nginx Logs (HTTP Scanners/Crawlers)
filenames:
  - /var/log/nginx/access.log
  - /var/log/nginx/error.log
labels:
  type: nginx
---
# 3. System Logs (Kernel/TCP Floods)
filenames:
  - /var/log/syslog
  - /var/log/kern.log
labels:
  type: syslog
YAML

echo " (3)Validating Config..."
if cscli config show > /dev/null; then
    echo "    Config syntax OK."
else
    echo "    !!! ERROR: Invalid Config. Check /etc/crowdsec/acquis.yaml"
    exit 1
fi

echo " (4)Reloading CrowdSec..."
systemctl reload crowdsec

echo "PHASE 3 COMPLETE: CrowdSec is now watching."
echo "Wait 1 hour, then run: 'sudo cscli alerts list'"
