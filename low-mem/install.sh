#!/bin/sh

daemon_install=$(daemon --version 2>/dev/null)

if [ $? -ne 0 ]; then
   sudo apt install daemon
fi

name=lowMemAlert
script_name=${name}.sh
chmod +x ./*.sh

sudo cp -f ${script_name} /usr/local/bin/
sudo cp -f init.d.sh /etc/init.d/${name}

sudo mkdir -p /var/log/${name}/
sudo chown -R $(whoami) /var/log/${name}/

sudo update-rc.d -f ${name} remove
sudo update-rc.d ${name} defaults