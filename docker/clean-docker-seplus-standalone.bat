@echo off

echo "stop the running containers seplus-standalone"
docker container stop seplus-standalone

echo "delete the stopped containers seplus-standalone"
docker container rm seplus-standalone