#!/bin/bash
knife ssh name:atomsource -a ipaddress  -x ubuntu -i nectar.pem "sudo chef-client"
