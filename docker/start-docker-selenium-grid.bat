@echo off

echo "Create a network 'my-grid' so that the containers can connect each other by container's name"
docker network create my-grid

echo "Create a hub 'my-hub' in network 'my-grid', by default the 'hub' is running on port 4444.
docker run -d -p 4444:4444 --net my-grid --name my-hub selenium/hub

echo "Create a node 'my-chrome' in network 'my-grid', by default the 'node' is running on port 5555. User can RDC the node container by port 32800 with 'VNC Viewer'"
docker run -d -p 32800:5900 --net my-grid --name my-chrome -e HUB_HOST=my-hub selenium/node-chrome-debug

echo "Create an other node 'my-firefox' in network 'my-grid', this node is running on port 5555. User can RDC the node container by port 32801 with 'VNC Viewer'"
docker run -d -p 32801:5900 --net my-grid --name my-firefox -e HUB_HOST=my-hub selenium/node-firefox-debug

echo "The status of network 'my-grid'"
docker network inspect my-grid

echo "The status of the containers"
docker container ls