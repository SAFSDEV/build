#!/usr/bin/env bash

if [ -z "$PORT" ]; then
  PORT=4444
fi
echo "Standalone server is going to run on port ${PORT}"

# Suppose that we are in the SeleniumPlus home directory
. bin/SeleniumPlusEnv.sh
#${SELENIUM_PLUS}/extra/RemoteServer.sh
${JAVA_HOME}/bin/java org.safs.selenium.webdriver.lib.RemoteDriverLauncher "-port ${PORT}" "SELENIUMSERVER_JVM_OPTIONS=-Xms512m -Xmx2g"
