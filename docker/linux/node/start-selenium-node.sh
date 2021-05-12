#!/usr/bin/env bash

if [ -z "$HUB_HOST" ]; then
  echo "Environment HUB_HOST is empty: Cannot connect to a running selenium Hub container" 1>&2
  exit 1
fi

if [ -z "$HUB_PORT" ]; then
  HUB_PORT=4444
fi
echo "Connecting to the Hub using the host ${HUB_HOST} and port ${HUB_PORT}"

if [ -z "$NODE_PORT" ]; then
  NODE_PORT=5555
fi
echo "Node is going to run on port ${NODE_PORT}"

#REMOTE_HOST_PARAM=""
#if [ ! -z "$REMOTE_HOST" ]; then
#  echo "REMOTE_HOST variable is set, appending -remoteHost"
#  REMOTE_HOST_PARAM="-remoteHost $REMOTE_HOST"
#fi

#if [ ! -z "$SE_OPTS" ]; then
#  echo "appending selenium options: ${SE_OPTS}"
#fi

#rm -f /tmp/.X*lock

#java ${JAVA_OPTS} -cp ${JAVA_CLASSPATH:-"/opt/selenium/*:."} org.openqa.grid.selenium.GridLauncherV3 \
#  -role node \
#  -hub http://$HUB_PORT_4444_TCP_ADDR:$HUB_PORT_4444_TCP_PORT/grid/register \
#  ${REMOTE_HOST_PARAM} \
#  -nodeConfig /opt/selenium/config.json \
#  ${SE_OPTS}

# Suppose that we are in the SeleniumPlus home directory
. bin/SeleniumPlusEnv.sh
${JAVA_HOME}/bin/java org.safs.selenium.webdriver.lib.RemoteDriverLauncher -safs.rmi.server "-role node -hub http://${HUB_HOST}:${HUB_PORT}/grid/register" "-port ${NODE_PORT}" "SELENIUMSERVER_JVM_OPTIONS=-Xms256m -Xmx4g"
