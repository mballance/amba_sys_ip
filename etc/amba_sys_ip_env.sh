#!/bin/sh

etc_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd)"
AMBA_SYS_IP=`cd $etc_dir/.. ; pwd`
export AMBA_SYS_IP

# Add a path to the simscripts directory
export PATH=$AMBA_SYS_IP/packages/simscripts/bin:$PATH

# Force the PACKAGES_DIR
export PACKAGES_DIR=$AMBA_SYS_IP/packages

