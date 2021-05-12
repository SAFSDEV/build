#!/usr/bin/env bash

#user can un-comment the following code to add default dns search domain
#echo "add dns default search domains dns.default.domain"
#cat >> /etc/resolv.conf <<EOF
#search dns.default.domain
#EOF

# dl-ssl.google.com can not be resolved by container's DNS
# We resolved the "dl-ssl.google.com" by https://ping.chinaz.com/dl-ssl.google.com and got the fastest IP is "172.217.194.93"
# append this IP to /etc/hosts
echo "add resolved IP for dl-ssl.google.com"
cat >> /etc/hosts <<EOF
172.217.194.93 dl-ssl.google.com
172.217.194.136 dl-ssl.google.com
172.217.194.91 dl-ssl.google.com
EOF

echo "export gradle on PATH. Attention, this PATH will not persist out of this shell!"
export PATH=$PATH:/usr/local/gradle/gradle/bin
echo "PATH=$PATH"