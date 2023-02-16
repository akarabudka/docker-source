#! /bin/bash

if [[ $(id -u) != 0 ]] ;
then
    sudo [ -d /root/.ssh/ ] && \
    sudo cp -aT /root/.ssh/. ~/.ssh/ && \
    sudo chown -R $(id -u):$(id -g) ~/.ssh && \
    chmod 700 ~/.ssh && \
    find ~/.ssh -type f -exec chmod 600 {} \;
fi
