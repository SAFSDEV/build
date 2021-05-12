#######################################################################################################
########################### Below content is copied from Dockerfile of selenium-docker-Base ############
#######################################################################################################

#================================================
# Based on ubuntu OS
#================================================
# Indicates that the windowsservercore image will be used as the base image.
FROM mcr.microsoft.com/windows:1809

# Metadata indicating an image maintainer.
LABEL authors="SAFS <safsdev@sas.com>"

#===  install chrome inside powershell   =====
ADD install_chrome.psl /windows/temp/install_chrome.ps1
RUN powershell.exe -executionpolicy bypass c:\windows\temp\install_chrome.ps1
#==============================================

#===  install firefox inside powershell   =====
ADD install_firefox.psl /windows/temp/install_firefox.ps1
RUN powershell.exe -executionpolicy bypass c:\windows\temp\install_firefox.ps1
#==============================================

#===  install seleniumplus inside powershell   =====
ADD install_seplus.psl /windows/temp/install_seplus.ps1
RUN powershell.exe -executionpolicy bypass c:\windows\temp\install_seplus.ps1
WORKDIR "C:\SeleniumPlus"
#==============================================

# Sets a "powershell" that will run each time a container is run from the new image.
CMD [ "powershell" ]
