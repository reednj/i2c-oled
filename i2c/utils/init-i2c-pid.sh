#!/bin/sh
#
# This creates a directory in the /var/run tmpfs so that we can store
# pid files for i2c applications.
#
DIR=/var/run/i2c
mkdir $DIR
chown root:i2c $DIR
chmod 775 $DIR
