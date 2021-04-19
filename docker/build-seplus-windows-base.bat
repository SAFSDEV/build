@echo off

rmdir /s /q runtime
mkdir runtime

copy windows\base\*.* runtime\

pushd runtime
REM The parameter "--add-host" can help to resovle the DNS problem
docker build --pull --no-cache --add-host dl-ssl.google.com:172.217.194.91 -t sepluswin .
popd