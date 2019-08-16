#!/bin/bash
# install script and service.

# install the script.
sudo cp SuspendFix.sh /usr/bin/

# install the service.
sudo cp SuspendFix.service /etc/systemd/system/

# enable the service.
sudo systemctl daemon-reload
sudo systemctl enable SuspendFix.service
