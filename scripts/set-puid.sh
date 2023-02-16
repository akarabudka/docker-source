#! /bin/bash

set -e

function fixUserId() {
  if [ -n "${PGID}" ] && [ "${PGID}" != "$(id -g developer)" ]; then
    echo "Switching to PGID ${PGID}..."
    sed -i -e "s/^developer:\([^:]*\):[0-9]*/developer:\1:${PGID}/" /etc/group
    sed -i -e "s/^developer:\([^:]*\):\([0-9]*\):[0-9]*/developer:\1:\2:${PGID}/" /etc/passwd
  fi
  if [ -n "${PUID}" ] && [ "${PUID}" != "$(id -u developer)" ]; then
    echo "Switching to PUID ${PUID}..."
    sed -i -e "s/^developer:\([^:]*\):[0-9]*:\([0-9]*\)/developer:\1:${PUID}:\2/" /etc/passwd
  fi
}

export -f fixUserId

if [[ $(id -u) != 0 ]] ;
then
    sudo bash -c "$(declare -f fixUserId); fixUserId"
else
    fixUserId
fi