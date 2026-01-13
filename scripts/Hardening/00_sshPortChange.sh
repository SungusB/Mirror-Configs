#!/bin/bash
set -e 

# CONFIGURATION
newPort="10022"  
configFile="/etc/ssh/sshd_config"
backupFile="/etc/ssh/sshd_config.bak.$(date +%F_%H%M)"

echo " (1)Backup SSH config being done."
cp $configFile $backupFile
echo "    saved to: $backupFile"

echo " (2)Updating UFW sets"
ufw allow $newPort/tcp
echo "    UFW port $newPort enabled"

echo " (3)Modifying ssh configs..."
if grep -q "^Port " $configFile; then
    sed -i "s/^Port .*/Port $newPort/" $configFile
elif grep -q "^#Port " $configFile; then
    sed -i "s/^#Port .*/Port $newPort/" $configFile
else
    # If no Port line exists, append it
    echo "Port $newPort" >> $configFile
fi

echo " (4)Checking configs..."
if /usr/sbin/sshd -t; then
    echo "    OKKKKKKKKKKKKKKKK."
else
    echo "    Error !!!!!!!!!!!!!!!!!!!!!!!!"
    cp $backupFile $configFile
    exit 1
fi

echo " (4)Restarting SSH Service..."
systemctl restart ssh

echo "----------------------------------------------------"
echo "SSH port changed to $newPort."
echo "TESTAR ABRINDO NOVO TERMINAL E ssh -p $newPort user@host"
echo "----------------------------------------------------"
