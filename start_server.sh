#!/bin/bash

vncserver &

# Change user
# Switch to user "user"


# Start noVNC
# /home/user/noVNC/utils/novnc_proxy --vnc 0.0.0.0:5901 --listen 0.0.0.0:6081

# sudo -i -u user bash << EOF
/home/docker/noVNC/utils/novnc_proxy --vnc 0.0.0.0:5901 --listen 0.0.0.0:6081
# EOF



