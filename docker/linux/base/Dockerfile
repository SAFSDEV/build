#######################################################################################################
########################### Below content is copied from Dockerfile of selenium-docker-Base ############
#######################################################################################################

#================================================
# Based on ubuntu OS
#================================================
FROM ubuntu:bionic-20191029
#FROM ubuntu
LABEL authors="SAFS <safsdev@sas.com>"

#================================================
# Customize sources for apt-get
#================================================
RUN  echo "deb http://archive.ubuntu.com/ubuntu bionic main universe\n" > /etc/apt/sources.list \
  && echo "deb http://archive.ubuntu.com/ubuntu bionic-updates main universe\n" >> /etc/apt/sources.list \
  && echo "deb http://security.ubuntu.com/ubuntu bionic-security main universe\n" >> /etc/apt/sources.list

# No interactive frontend during docker build
#ENV DEBIAN_FRONTEND=noninteractive \
#    DEBCONF_NONINTERACTIVE_SEEN=true

#========================
# Miscellaneous packages
# Includes JDK used for executing Java programs
#========================
RUN apt-get -y update \
  && apt-get -y --no-install-recommends install \
    bzip2 \
    ca-certificates \
    openjdk-8-jdk \
    tzdata \
    sudo \
    unzip \
    wget \
    jq \
	pv \
    curl \
	iputils-ping \
    supervisor \
    gnupg2 \
    pcregrep \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/* \
  && sed -i 's/securerandom\.source=file:\/dev\/random/securerandom\.source=file:\/dev\/urandom/' ./usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/java.security

#========================
# Install Gradle
#========================
RUN wget --no-verbose -O /tmp/gradle-6.5-bin.zip https://services.gradle.org/distributions/gradle-6.5-bin.zip \
    && mkdir /usr/local/gradle \
    && unzip -d /usr/local/gradle /tmp/gradle-6.5-bin.zip \
    && mv /usr/local/gradle/gradle-6.5 /usr/local/gradle/gradle \
    && ln -s /usr/local/gradle/gradle/bin/gradle /usr/bin/gradle \
    && rm /tmp/gradle-6.5-bin.zip

#===================
# Timezone settings
# Possible alternative: https://github.com/docker/docker/issues/3359#issuecomment-32150214
#===================
ENV TZ "UTC"
RUN echo "${TZ}" > /etc/timezone \
  && dpkg-reconfigure --frontend noninteractive tzdata

#========================================
# Add normal user with passwordless sudo
#========================================
RUN useradd seluser \
         --shell /bin/bash  \
         --create-home \
  && usermod -a -G sudo seluser \
  && echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers \
  && echo 'seluser:secret' | chpasswd
#Lei: We don't set the HOME to a fixed user
#ENV HOME=/home/seluser

#======================================
# Add Grid check script
#======================================
COPY entry_point.sh /opt/bin/

#======================================
# Add Supervisor configuration file
#======================================
COPY supervisord.conf /etc

#==========
# Selenium & relaxing permissions for OpenShift and other non-sudo environments
#==========
RUN  mkdir -p /opt/selenium /var/run/supervisor /var/log/supervisor \
  && touch /opt/selenium/config.json \
  && chmod -R 777 /opt/selenium /var/run/supervisor /var/log/supervisor /etc/passwd \
  && wget --no-verbose https://selenium-release.storage.googleapis.com/3.141/selenium-server-standalone-3.141.59.jar \
    -O /opt/selenium/selenium-server-standalone.jar \
  && chgrp -R 0 /opt/selenium ${HOME} /var/run/supervisor /var/log/supervisor \
  && chmod -R g=u /opt/selenium ${HOME} /var/run/supervisor /var/log/supervisor

#===================================================
# Run the following commands as non-privileged user
#===================================================
USER seluser

CMD ["/opt/bin/entry_point.sh"]
##########################################################################################################

###########################################################################################################
########################### Below content is copied from Dockerfile of selenium-docker-NodeBase ###########
###########################################################################################################
USER root

#==============
# Xvfb
#==============
RUN apt-get update -y \
  && apt-get -y install \
    xvfb \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

#==============================
# Locale and encoding settings
#==============================
ENV LANG_WHICH en
ENV LANG_WHERE US
ENV ENCODING UTF-8
ENV LANGUAGE ${LANG_WHICH}_${LANG_WHERE}.${ENCODING}
ENV LANG ${LANGUAGE}
# Layer size: small: ~9 MB
# Layer size: small: ~9 MB MB (with --no-install-recommends)
RUN apt-get -y update \
  && apt-get -y --no-install-recommends install \
    language-pack-en \
    tzdata \
    locales \
  && locale-gen ${LANGUAGE} \
  && dpkg-reconfigure --frontend noninteractive locales \
  && apt-get -qyy autoremove \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get -qyy clean

#================
# Font libraries
#================
# libfontconfig            ~1 MB
# libfreetype6             ~1 MB
# xfonts-cyrillic          ~2 MB
# xfonts-scalable          ~2 MB
# fonts-liberation         ~3 MB
# fonts-ipafont-gothic     ~13 MB
# fonts-wqy-zenhei         ~17 MB
# fonts-tlwg-loma-otf      ~300 KB
# ttf-ubuntu-font-family   ~5 MB
#   Ubuntu Font Family, sans-serif typeface hinted for clarity
# Removed packages:
# xfonts-100dpi            ~6 MB
# xfonts-75dpi             ~6 MB
# Regarding fonts-liberation see:
#  https://github.com/SeleniumHQ/docker-selenium/issues/383#issuecomment-278367069
# Layer size: small: 36.28 MB (with --no-install-recommends)
# Layer size: small: 36.28 MB
RUN apt-get -y update \
  && apt-get -y --no-install-recommends install \
    libfontconfig \
    libfreetype6 \
    xfonts-cyrillic \
    xfonts-scalable \
    fonts-liberation \
    fonts-ipafont-gothic \
    fonts-wqy-zenhei \
    fonts-tlwg-loma-otf \
    ttf-ubuntu-font-family \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get -qyy clean

#===================================================
# Run the following commands as non-privileged user
#===================================================

USER seluser

#======================================
# Scripts to run Selenium Node and XVFB
#======================================
COPY start-xvfb.sh \
      /opt/bin/

#==============================
# Supervisor configuration file
#==============================
COPY selenium.node.conf /etc/supervisor/conf.d/


#============================
# Some configuration options
#============================
ENV SCREEN_WIDTH 1360
ENV SCREEN_HEIGHT 1020
ENV SCREEN_DEPTH 24
ENV SCREEN_DPI 96
ENV DISPLAY :99.0
ENV START_XVFB true

#========================
# Selenium Configuration
#========================
# As integer, maps to "maxInstances"
ENV NODE_MAX_INSTANCES 1
# As integer, maps to "maxSession"
ENV NODE_MAX_SESSION 1
# As address, maps to "host"
ENV NODE_HOST 0.0.0.0
# As integer, maps to "port"
ENV NODE_PORT 5555
# In milliseconds, maps to "registerCycle"
ENV NODE_REGISTER_CYCLE 5000
# In milliseconds, maps to "nodePolling"
ENV NODE_POLLING 5000
# In milliseconds, maps to "unregisterIfStillDownAfter"
ENV NODE_UNREGISTER_IF_STILL_DOWN_AFTER 60000
# As integer, maps to "downPollingLimit"
ENV NODE_DOWN_POLLING_LIMIT 2
# As string, maps to "applicationName"
ENV NODE_APPLICATION_NAME ""
# Debug
ENV GRID_DEBUG false

# Following line fixes https://github.com/SeleniumHQ/docker-selenium/issues/87
ENV DBUS_SESSION_BUS_ADDRESS=/dev/null

# Creating base directory for Xvfb
RUN  sudo mkdir -p /tmp/.X11-unix && sudo chmod 1777 /tmp/.X11-unix
##########################################################################################################

###############################################################################################################
########################### Below content is copied from Dockerfile of selenium-docker-NodeFirefox ############
###############################################################################################################
USER root

#=========
# Firefox
#=========
ARG FIREFOX_VERSION=latest
RUN FIREFOX_DOWNLOAD_URL=$(if [ $FIREFOX_VERSION = "latest" ] || [ $FIREFOX_VERSION = "nightly-latest" ] || [ $FIREFOX_VERSION = "devedition-latest" ]; then echo "https://download.mozilla.org/?product=firefox-$FIREFOX_VERSION-ssl&os=linux64&lang=en-US"; else echo "https://download-installer.cdn.mozilla.net/pub/firefox/releases/$FIREFOX_VERSION/linux-x86_64/en-US/firefox-$FIREFOX_VERSION.tar.bz2"; fi) \
  && apt-get update -y \
  && apt-get -y --no-install-recommends install firefox \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/* \
  && wget --no-verbose -O /tmp/firefox.tar.bz2 $FIREFOX_DOWNLOAD_URL \
  && apt-get -y purge firefox \
  && rm -rf /opt/firefox \
  && tar -C /opt -xjf /tmp/firefox.tar.bz2 \
  && rm /tmp/firefox.tar.bz2 \
  && mv /opt/firefox /opt/firefox-$FIREFOX_VERSION \
  && ln -fs /opt/firefox-$FIREFOX_VERSION/firefox /usr/bin/firefox

#============
# GeckoDriver
#============
ARG GECKODRIVER_VERSION=latest
RUN GK_VERSION=$(if [ ${GECKODRIVER_VERSION:-latest} = "latest" ]; then echo "0.26.0"; else echo $GECKODRIVER_VERSION; fi) \
  && echo "Using GeckoDriver version: "$GK_VERSION \
  && wget --no-verbose -O /tmp/geckodriver.tar.gz https://github.com/mozilla/geckodriver/releases/download/v$GK_VERSION/geckodriver-v$GK_VERSION-linux64.tar.gz \
  && rm -rf /opt/geckodriver \
  && tar -C /opt -zxf /tmp/geckodriver.tar.gz \
  && rm /tmp/geckodriver.tar.gz \
  && mv /opt/geckodriver /opt/geckodriver-$GK_VERSION \
  && chmod 755 /opt/geckodriver-$GK_VERSION \
  && ln -fs /opt/geckodriver-$GK_VERSION /usr/bin/geckodriver

USER seluser

# commented out by Lei: we don't need this firefox configuration for now
# Generating a default config during build time
#COPY generate_config_firefox /opt/bin/generate_config_firefox
#RUN /opt/bin/generate_config_firefox > /opt/selenium/config.firefox.json

#==========
# Relaxing permissions for OpenShift and other non-sudo environments
#==========
RUN sudo chmod -R 777 ${HOME} \
  && sudo chgrp -R 0 ${HOME} \
  && sudo chmod -R g=u ${HOME}
###################################################################################################

##############################################################################################################
########################### Below content is copied from Dockerfile of selenium-docker-NodeChrome ############
##############################################################################################################
USER root

#COPY addGoogleHost.sh /opt/bin/addGoogleHost.sh
#RUN /opt/bin/addGoogleHost.sh
#RUN echo "172.217.194.93 dl-ssl.google.com" >> /etc/hosts
#RUN echo "172.217.194.136 dl-ssl.google.com" >> /etc/hosts
#RUN echo "172.217.194.91 dl-ssl.google.com" >> /etc/hosts
#RUN more /etc/hosts

#add more DNS servers: "172.27.16.28", "172.27.16.18", "172.26.40.12"
#RUN echo "nameserver 172.27.16.28" >> /etc/resolv.conf
#RUN echo "nameserver 172.27.16.18" >> /etc/resolv.conf
#RUN echo "nameserver 172.26.40.12" >> /etc/resolv.conf
#RUN  more /etc/resolv.conf

#============================================
# Google Chrome
#============================================
# can specify versions by CHROME_VERSION;
#  e.g. google-chrome-stable=53.0.2785.101-1
#       google-chrome-beta=53.0.2785.92-1
#       google-chrome-unstable=54.0.2840.14-1
#       latest (equivalent to google-chrome-stable)
#       google-chrome-beta  (pull latest beta)
#============================================
ARG CHROME_VERSION="google-chrome-stable"
RUN wget -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add \
  && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update -y \
  && apt-get -y install \
    ${CHROME_VERSION:-google-chrome-stable} \
  && rm /etc/apt/sources.list.d/google-chrome.list \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

#=================================
# Chrome Launch Script Wrapper
#=================================
COPY wrap_chrome_binary /opt/bin/wrap_chrome_binary
RUN /opt/bin/wrap_chrome_binary

USER seluser

#============================================
# Chrome webdriver
#============================================
# can specify versions by CHROME_DRIVER_VERSION
# Latest released version will be used by default
#============================================
ARG CHROME_DRIVER_VERSION
RUN if [ -z "$CHROME_DRIVER_VERSION" ]; \
  then CHROME_MAJOR_VERSION=$(google-chrome --version | sed -E "s/.* ([0-9]+)(\.[0-9]+){3}.*/\1/") \
    && CHROME_DRIVER_VERSION=$(wget --no-verbose -O - "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${CHROME_MAJOR_VERSION}"); \
  fi \
  && echo "Using chromedriver version: "$CHROME_DRIVER_VERSION \
  && wget --no-verbose -O /tmp/chromedriver_linux64.zip https://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip \
  && rm -rf /opt/selenium/chromedriver \
  && unzip /tmp/chromedriver_linux64.zip -d /opt/selenium \
  && rm /tmp/chromedriver_linux64.zip \
  && mv /opt/selenium/chromedriver /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION \
  && chmod 755 /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION \
  && sudo ln -fs /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION /usr/bin/chromedriver

# commented out by Lei: we don't need this firefox configuration for now
# Generating a default config during build time
#COPY generate_config_chrome /opt/bin/generate_config_chrome
#RUN /opt/bin/generate_config_chrome > /opt/selenium/config.chrome.json

###################################################################################################


##############################################################################################################
########################### Below content is copied from Dockerfile of selenium-docker-NodeFirefoxDebug ######
##############################################################################################################
USER root

#=====
# VNC
#=====
RUN apt-get update -y \
  && apt-get -y install \
  x11vnc \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

#=========
# fluxbox
# A fast, lightweight and responsive window manager
#=========
RUN apt-get update -y \
  && apt-get -y install \
    fluxbox \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

#==============================
# Generating the VNC password as root
# So the service can be started with root
#==============================
RUN mkdir -p ${HOME}/.vnc \
  && x11vnc -storepasswd secret ${HOME}/.vnc/passwd


USER seluser

#==============================
# Generating the VNC password as seluser
# So the service can be started with seluser
#==============================
RUN mkdir -p ${HOME}/.vnc \
  && x11vnc -storepasswd secret ${HOME}/.vnc/passwd

#==========
# Relaxing permissions for OpenShift and other non-sudo environments
#==========
RUN sudo chmod -R 777 ${HOME} \
  && sudo chgrp -R 0 ${HOME} \
  && sudo chmod -R g=u ${HOME}

#==============================
# Scripts to run fluxbox and x11vnc
#==============================
COPY start-fluxbox.sh \
      start-vnc.sh \
      /opt/bin/

#==============================
# Supervisor configuration file
#==============================
COPY selenium-debug.conf /etc/supervisor/conf.d/

EXPOSE 5900
##############################################################################################################

##############################################################################################################
########################### SeleniumPluls Setup                                                         ######
##############################################################################################################
USER root

#====================================================
# Add the script for adding default dns search domain
# export gradle on PATH
#====================================================
COPY seleniumplus.sh /opt/bin/seleniumplus.sh

#==============================
# Supervisor configuration file
#==============================
COPY seleniumplus.conf /etc/supervisor/conf.d/     

#=====================
# Install SeleniumPlus
#=====================
#Download the SeleniumPlus installer zip file
RUN wget --progress=bar:force -O /tmp/TestDesigner.tar.gz http://safsbuild.na.sas.com:81/jenkins/job/SeleniumPlus_Linux/lastSuccessfulBuild/artifact/dist/TestDesigner.tar.gz
RUN mkdir /usr/local/seleniumplus
#Change the working directory to "usr/local/seleniumplus", the following command like "RUN" will run within that directory.
WORKDIR /usr/local/seleniumplus
#pv Pipe Viewer for monitoring the progress of data through a pipeline.
RUN pv /tmp/TestDesigner.tar.gz | tar xzf - -C /usr/local/seleniumplus
#xvfb-run command will take care of setting up the virtual X Server environment, our SEPlus installation needs graphic environment.
RUN cd install \
    && chmod a+x STAF*.bin *.sh \
    && xvfb-run ./SetupSeleniumPlus.sh --default
#In previous steps we have downloaded the latest matched browser driver for chrome and firefox, we copy them to selenimplus folder "extra"
RUN cd extra && rm chromedriver && cp /usr/bin/chromedriver .
RUN cd extra && rm geckodriver && cp /usr/bin/geckodriver .


##############################################################################################################
