#! /bin/bash

set-puid
add-host-alias
copy-ssh-keys
sudo apache2-foreground
exec "$@"
