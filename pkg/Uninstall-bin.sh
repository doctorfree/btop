#!/bin/bash

BTOP_DIRS="/usr/share/btop"

BTOP_FILES="/usr/bin/btop \
/usr/share/applications/btop.desktop \
/usr/share/man/man1/btop.1"

user=`id -u -n`

[ "${user}" == "root" ] || {
  echo "Uninstall-bin.sh must be run as the root user."
  echo "Use 'sudo ./Uninstall-bin.sh ...'"
  echo "Exiting"
  exit 1
}

rm -f ${BTOP_FILES}
rm -rf ${BTOP_DIRS}
if [ -f /etc/profile.d/btop.sh ]
then
  rm -f /etc/profile.d/btop.sh
fi
