#!/bin/bash

if [[ $EUID -eq 0 ]]; then
  echo "taiga-scripts doesn't works properly if it used with root user." 1>&2
  exit 1
fi

source ./setup-devel.sh

# Post Setup Services
# Using systemd instead, disabled circus
# source ./scripts/setup-circus.sh

source ./scripts/setup-systemd.sh
source ./scripts/setup-nginx.sh
source ./scripts/setup-certbot.sh

# Display install info
source ./scripts/setup-post-install.sh
