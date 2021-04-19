#!/usr/bin/env bash

rm -rf runtime
mkdir runtime

cp linux/base/* runtime/
yes | cp -rf linux/hub/* runtime/

pushd runtime
#The parameter "--add-host" can help to resovle the DNS problem
docker build --pull --no-cache --add-host dl-ssl.google.com:172.217.194.91 -t seplus-hub .
popd