#!/bin/sh -eux

if dpkg-query -W -f='${Status}' systemd 2>/dev/null | cut -f 3 -d ' ' | grep -q '^installed$'; then
	echo "==> Installing PAM module for systemd to prevent Vagrant/SSH hangs"
	apt-get -y install libpam-systemd
fi
