#!/bin/bash
# uninstall script and service.

# disable the service.
sudo systemctl disable SuspendFix.service

# uninstall the script.
sudo rm /usr/bin/SuspendFix.sh

# uninstall the service.
sudo rm /etc/systemd/system/SuspendFix.service