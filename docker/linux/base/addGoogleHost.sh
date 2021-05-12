#!/usr/bin/env bash

# dl-ssl.google.com can not be resolved by container's DNS
# We resolved the "dl-ssl.google.com" by https://ping.chinaz.com/dl-ssl.google.com and got the fatest ip is "172.217.194.93"
# append this IP to /etc/hosts
cat >> /etc/hosts <<EOF
172.217.194.93 dl-ssl.google.com
172.217.194.136 dl-ssl.google.com
172.217.194.91 dl-ssl.google.com
EOF