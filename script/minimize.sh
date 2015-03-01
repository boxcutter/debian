#!/bin/bash -eux

echo "==> Disk usage before minimization"
df -h

echo "==> Installed packages before cleanup"
dpkg --get-selections | grep -v deinstall

# Remove some packages to get a minimal install
echo "==> Removing all linux kernels except the currrent one"
dpkg --list | awk '{ print $2 }' | grep 'linux-image-3.*-generic' | grep -v $(uname -r) | xargs apt-get -y purge
echo "==> Removing linux headers"
dpkg --list | awk '{ print $2 }' | grep linux-headers | xargs apt-get -y purge
rm -rf /usr/src/linux-headers*
echo "==> Removing linux source"
dpkg --list | awk '{ print $2 }' | grep linux-source | xargs apt-get -y purge
echo "==> Removing development packages"
dpkg --list | awk '{ print $2 }' | grep -- '-dev$' | xargs apt-get -y purge
echo "==> Removing documentation"
dpkg --list | awk '{ print $2 }' | grep -- '-doc$' | xargs apt-get -y purge
echo "==> Removing development tools"
#dpkg --list | grep -i compiler | awk '{ print $2 }' | xargs apt-get -y purge
#apt-get -y purge cpp gcc g++
apt-get -y purge build-essential
echo "==> Removing X11 libraries"
apt-get -y purge libx11-data xauth libxmuu1 libxcb1 libx11-6 libxext6
echo "==> Removing obsolete networking components"
apt-get -y purge ppp pppconfig pppoeconf
echo "==> Removing other oddities"
apt-get -y purge popularity-contest installation-report wireless-tools wpasupplicant

# Only remove ruby if not required by the CM
if ! [[ ${CM} == 'puppet' ]]; then
  echo "==> Removing default system Ruby"
  apt-get -y purge ruby ri doc libffi5
fi

echo "==> Removing default system Python"
apt-get -y purge python-dbus libnl1 python-smartpm python-twisted-core libiw30 python-twisted-bin libdbus-glib-1-2 python-pexpect python-pycurl python-serial python-gobject python-pam python-openssl

# Clean up the apt cache
echo "==> Cleaning up the apt cache"
apt-get -y autoremove --purge
apt-get -y autoclean
apt-get -y clean

# Clean up orphaned packages with deborphan
echo "==> Cleaning up orphaned packages with deborphan"
apt-get -y install deborphan
while [ -n "$(deborphan --guess-all --libdevel)" ]; do
    deborphan --guess-all --libdevel | xargs apt-get -y purge
done
apt-get -y purge deborphan dialog

echo "==> Removing man pages"
find /usr/share/man -type f -delete
echo "==> Removing APT files"
find /var/lib/apt -type f -delete
echo "==> Removing anything in /usr/src"
rm -rf /usr/src/*
echo "==> Removing any docs"
find /usr/share/doc -type f -delete
echo "==> Removing caches"
find /var/cache -type f -delete
echo "==> Removing groff info lintian linda"
rm -rf /usr/share/groff/* /usr/share/info/* /usr/share/lintian/* /usr/share/linda/*

echo "==> Disk usage after cleanup"
df -h
