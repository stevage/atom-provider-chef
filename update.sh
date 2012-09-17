#!/bin/bash -x
source settings.sh
knife ssh name:$CHEF_HOST -a ipaddress  -x $CHEF_ACCOUNT -i nectar.pem "sudo chef-client"
