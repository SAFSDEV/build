@echo off

echo "Create a standalone server 'seplus-standalone', by default the 'standalone' is running on port 4444. User can RDC the standalone container by port 32800 with 'VNC Viewer'"
docker run -d  -p 32800:5900 --name seplus-standalone seplus-standalone

echo "The status of the containers"
docker container ls