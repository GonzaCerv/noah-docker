#!/usr/bin/env bash

# Author:        Gonzalo Cervetti (cervetti.g@gmail.com)
#
# Description:   Sets ROSCORE to start locally 

sed -i 's@ROS_HOSTNAME=.*@ROS_HOSTNAME=localhost@' ~/.bashrc
sed -i 's@ROS_MASTER_URI=.*@ROS_MASTER_URI=http://localhost:11311@' ~/.bashrc
source ~/.bashrc