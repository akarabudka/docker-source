#! /bin/bash

set -e

function fixInternalHost() {
    DOCKER_INTERNAL_HOST="host.docker.internal"
    if ! grep $DOCKER_INTERNAL_HOST /etc/hosts > /dev/null ; then
        DOCKER_INTERNAL_IP=$(printf "%d.%d.%d.%d" $(awk '$2 == 00000000 && $7 == 00000000 { for (i = 8; i >= 2; i=i-2) { print "0x" substr($3, i-1, 2) } }' /proc/net/route))
        echo -e "$DOCKER_INTERNAL_IP\t$DOCKER_INTERNAL_HOST" | tee -a /etc/hosts > /dev/null
        echo "*** Added $DOCKER_INTERNAL_HOST to /etc/hosts ***"
    fi
}

export -f fixInternalHost

if [[ $(id -u) != 0 ]] ;
then
    sudo bash -c "$(declare -f fixInternalHost); fixInternalHost"
else
    fixInternalHost
fi
