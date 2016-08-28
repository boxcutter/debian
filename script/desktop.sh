#!/bin/bash

if [[ ! "$DESKTOP" =~ ^(true|yes|on|1|TRUE|YES|ON])$ ]]; then
  exit
fi

apt-get install -y task-gnome-desktop

# just in case the previous command failed to download all packages do it again
apt-get install -y task-gnome-desktop

GDM_CONFIG=/etc/gdm3/daemon.conf

# Configure gdm autologin.

if [ -f $GDM_CONFIG ]; then
    sed -i s/"daemon]$"/"daemon]\nAutomaticLoginEnable=true\nAutomaticLogin=vagrant"/ $GDM_CONFIG
fi

# Need to disable NetworkManager because it overwrites vagrant's
# settings in /etc/resolv.conf with empty content in the first boot.
# So, DNS doesn't work on the first boot.
#
# Maybe there is a better solution then disabling the service.
systemctl disable NetworkManager.service

echo "==> Removing desktop components"
apt-get -y purge gnome-getting-started-docs
apt-get -y purge $(dpkg --get-selections | grep -v deinstall | grep libreoffice | cut -f 1)
