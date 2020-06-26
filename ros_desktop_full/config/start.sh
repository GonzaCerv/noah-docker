#!/bin/bash

# Required services for mDNS to work on debian
/etc/init.d/dbus start
/etc/init.d/avahi-daemon start
