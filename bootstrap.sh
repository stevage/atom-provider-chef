#!/bin/bash
knife bootstrap 115.146.92.243 -x ubuntu -i nectar.pem --sudo -d ubuntu12.04-gems -E prod -r 'role[provider]'
