# SeleniumPlus Docker images
---
SeleniumPlus can ran in docker, we have provided SeleniumPlus Linux version docker images (based on ubuntu) 
and SeleniumPlus widnows version docker images (based on mcr.microsoft.com/windows).

## Prerequisites
Docker must has been installed. For windows, you can install [Docker Desktop](https://www.docker.com/products/docker-desktop);
For other OS, you can install [Docker Engine](https://docs.docker.com/engine/install/).

## Build SeleniumPlus images
1. SeleniumPlus base image provides a static environment. "SeleniumPlus", "chrome", "firefox", "chromedriver" and "geckodriver" have been installed on it.
   
   Build SeleniumPlus Linux base image
   ```bash
   #on windows
   build-seplus-linux-base.bat
   #on linux
   build-seplus-linux-base.sh
   ```

   Build SeleniumPlus Windows base image
   ```
   build-seplus-windows-base.bat
   ```   
   
2. SeleniumPlus standalone image provides an environment with "SeleniumPlus", "chrome", "firefox", "chromedriver" and "geckodriver" installed on it, and the "selenium server" running on it.
   
   Build SeleniumPlus Linux standalone image
   ```bash
   #on windows
   build-seplus-linux-standalone.bat
   #on linux
   build-seplus-linux-standalone.sh
   ```

3. SeleniumPlus hub image provides an environment with "SeleniumPlus", "chrome", "firefox", "chromedriver" and "geckodriver" installed on it, and the "selenium hub" running on it.
   
   Build SeleniumPlus Linux hub image
   ```bash
   #on windows
   build-seplus-linux-hub.bat
   #on linux
   build-seplus-linux-hub.sh
   ```

4. SeleniumPlus node image provides an environment with "SeleniumPlus", "chrome", "firefox", "chromedriver" and "geckodriver" installed on it, and the "selenium node" running on it.
   
   Build SeleniumPlus Linux node image
   ```bash
   #on windows
   build-seplus-linux-node.bat
   #on linux
   build-seplus-linux-node.sh
   ```

## Verify SeleniumPlus images

   Run command
   ```
   docker image ls
   ```   
   
   We should be able to see the seleniumplus images listed as below:
   ```
   REPOSITORY                   TAG                 IMAGE ID            CREATED             SIZE
   seplus                       latest              e612d15915b1        9 hours ago         3.49GB
   seplus-hub                   latest              107a507ea363        11 hours ago        3.49GB
   seplus-node                  latest              0742eb123220        23 hours ago        3.49GB
   seplus-standalone            latest              0742eb123220        23 hours ago        3.49GB
   ```
   
## Run test with SeleniumPlus images

1. **In grid mode** 
   1. The script **start-docker-seplus-grid.bat** will start a grid containing a hub 'seplus-hub', 2 nodes 'seplus-node' 'seplus-node2' and a test container 'seplus-test'.
      ```
      start-docker-seplus-grid.bat
      ```
   
   2. Once the script stop, we should see the output showing the running containers (seplus grid).
      ```
      CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                     NAMES
      1bf22e778035        seplus              "/opt/bin/entry_poin…"   7 seconds ago       Up 5 seconds        0.0.0.0:32803->5900/tcp   seplus-test
      fbedc8c5a4ab        seplus-node         "/opt/bin/entry_poin…"   12 seconds ago      Up 10 seconds       0.0.0.0:32802->5900/tcp   seplus-node2
      4ef27993ba11        seplus-node         "/opt/bin/entry_poin…"   17 seconds ago      Up 14 seconds       0.0.0.0:32801->5900/tcp   seplus-node
      cfc42046587d        seplus-hub          "/opt/bin/entry_poin…"   22 seconds ago      Up 19 seconds       0.0.0.0:32800->5900/tcp   seplus-hub
      ```
   
   3. Then we can use the **VNC Viewer** to Remote-Desktop-Connect these containers
      * connect 'seplus-hub' by 'localhost:32800', we can see the "Selenium hub Server" is running on port 4444 
      * connect 'seplus-node' by 'localhost:32801', we can see a "Selenium node Server" is running on port 5555  
      * connect 'seplus-node2' by 'localhost:32802', we can see the other "Selenium node Server" is running on port 5678
      * connect 'seplus-test' by 'localhost:32803', this is the container used for running test.
   
   4. Run test from container 'seplus-test' 
      In the "Remote Desktop" ('localhost:32803' for 'seplus-test'), start a bash terminal and run
      ```
      eclipse/eclipse &
      ```
      We should see the SeleniumPlus IDE gets started, then create a SAMPLE seleniumplus test, and modify the **test.ini** configuration file as below:
      
      ```
      SELENIUMHOST=seplus-hub
      SELENIUMPORT=4444
      SELENIUMNODE=seplus-node:5555
      ```
      Now if we run the test, we can see the browser gets started and the test runs in the "Remote Desktop" ('localhost:32801' for 'seplus-node')
      
      If we modify the **test.ini** configuration file as below:
      ```
      SELENIUMHOST=seplus-hub
      SELENIUMPORT=4444
      SELENIUMNODE=seplus-node2:5678
      ```
      Now if we run the test, we can see the browser gets started and the test runs in the "Remote Desktop" ('localhost:32802' for 'seplus-node2')
   5. Finally we can clean up the grid by following command
      ```
      clean-docker-seplus-grid.bat
      ```
2. **In standalone mode**    
   1. The script **start-docker-seplus-standalone.bat** will start a standalone server 'seplus-standalone'.
      ```
      start-docker-seplus-standalone.bat
      ```
   2. Once the script stop, we should see the output showing the running container (seplus standalone).
      ```
      CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                     NAMES
      aa5454a010e9        seplus-standalone   "/opt/bin/entry_poin…"   6 seconds ago       Up 3 seconds        0.0.0.0:32800->5900/tcp   seplus-standalone
      ```
   3. Then we can use the **VNC Viewer** to Remote-Desktop-Connect this container
      * connect 'seplus-standalone' by 'localhost:32800', we can see the "Selenium standalone Server" is running on port 4444       
 
   4. Run test from container 'seplus-standalone' 
      In the "Remote Desktop" ('localhost:32800' for 'seplus-standalone'), start a bash terminal and run
      ```
      eclipse/eclipse &
      ```
      We should see the SeleniumPlus IDE gets started, then create a SAMPLE seleniumplus test. Now if we run the test, we can see the browser gets started and the test runs.
      

   5. Finally we can clean up the standalone server by following command
      ```
      clean-docker-seplus-standalone.bat
      ```     
