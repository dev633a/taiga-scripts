#!/bin/bash

source /etc/os-release
if [ "$VERSION_ID" != "20.04" ]; then
  echo "This script is not compatible with your current OS: $PRETTY_NAME"
  echo "Please try to install on Ubuntu-20.04 LTS"
  exit 1
else
  echo "Installing taigaio on $PRETTY_NAME"
  echo "Please wait a moment, you will be asked questions after initial update..."
fi
sleep 3
