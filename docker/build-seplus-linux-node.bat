@echo off

rmdir /S /Q runtime
mkdir runtime

copy linux\base\*.* runtime\
copy /Y linux\node\*.* runtime\

pushd runtime
REM The parameter "--add-host" can help to resovle the DNS problem
docker build --pull --no-cache --add-host dl-ssl.google.com:172.217.194.91 -t seplus-node .
popd