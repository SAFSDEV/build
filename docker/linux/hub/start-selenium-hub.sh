#!/usr/bin/env bash

#start the selenium hub server  
. bin/SeleniumPlusEnv.sh
${JAVA_HOME}/bin/java org.safs.selenium.webdriver.lib.RemoteDriverLauncher "-role hub" "SELENIUMSERVER_JVM_OPTIONS=-Xms512m -Xmx2g"