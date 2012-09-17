#!/bin/bash -x
source ./settings.sh
knife bootstrap $CHEF_IP -x $CHEF_ACCOUNT --no-host-key-verify -i nectar.pem --sudo $CHEF_BOOTSTRAP_ARGS
