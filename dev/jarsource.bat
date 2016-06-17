;REM =============================================
;REM Assumes project is on Windows C: Drive.
;REM =============================================

C:
cd \sqarepos\ddengine\datastorej

;REM SET JRE=C:\j2sdk1.4.2_14\bin
;REM SET JRE=C:\Progra~1\Java\jdk1.5.0_21\bin
SET JRE=C:\Progra~1\Java\jdk1.7.0_40\bin

%JRE%\jar cfM .\classes\_safs-source-update.zip TestScript.* *.dat RunProcessContainer.* *ResourceBundle*.properties safsjvmagent.properties
%JRE%\jar uf .\classes\_safs-source-update.zip com\jayway\android\robotium\remotecontrol\install\*.java
%JRE%\jar uf .\classes\_safs-source-update.zip com\jayway\android\robotium\remotecontrol\*.java
%JRE%\jar uf .\classes\_safs-source-update.zip com\jayway\android\robotium\remotecontrol\solo\*.java
%JRE%\jar uf .\classes\_safs-source-update.zip org\safs\*.java
%JRE%\jar uf .\classes\_safs-source-update.zip org\safs\abbot\*.* 
%JRE%\jar uf .\classes\_safs-source-update.zip org\safs\android\*.* 
%JRE%\jar uf .\classes\_safs-source-update.zip org\safs\autoit\*.* 
%JRE%\jar uf .\classes\_safs-source-update.zip org\safs\cukes\*.* 
%JRE%\jar uf .\classes\_safs-source-update.zip org\safs\custom\*.* 
%JRE%\jar uf .\classes\_safs-source-update.zip org\safs\image\*.*
%JRE%\jar uf .\classes\_safs-source-update.zip org\safs\install\*.*
%JRE%\jar uf .\classes\_safs-source-update.zip org\safs\ios\*.*
%JRE%\jar uf .\classes\_safs-source-update.zip org\safs\jvmagent\*.*
%JRE%\jar uf .\classes\_safs-source-update.zip org\safs\logging\*.*
%JRE%\jar uf .\classes\_safs-source-update.zip org\safs\model\*.* 
%JRE%\jar uf .\classes\_safs-source-update.zip org\safs\natives\*.* 
%JRE%\jar uf .\classes\_safs-source-update.zip org\safs\net\*.* 
%JRE%\jar uf .\classes\_safs-source-update.zip org\safs\rational\*.* 
%JRE%\jar uf .\classes\_safs-source-update.zip org\safs\reflect\*.*
%JRE%\jar uf .\classes\_safs-source-update.zip org\safs\rmi\*.*
%JRE%\jar uf .\classes\_safs-source-update.zip org\safs\robot\*.*
%JRE%\jar uf .\classes\_safs-source-update.zip org\safs\staf\*.*
%JRE%\jar uf .\classes\_safs-source-update.zip org\safs\text\*.*
%JRE%\jar uf .\classes\_safs-source-update.zip org\safs\tools\*.*
%JRE%\jar uf .\classes\_safs-source-update.zip org\safs\selenium\*.* 
%JRE%\jar uf .\classes\_safs-source-update.zip org\safs\xml\*.*
%JRE%\jar uf .\classes\_safs-source-update.zip org\slf4j\impl\*.*
%JRE%\jar uf .\classes\_safs-source-update.zip org\w3c\tools\codec\*.*
%JRE%\jar uf .\classes\_safs-source-update.zip resources\TestScrip*.* resources\RunProcessContaine*.* resources\DatastoreDefinition.rftdsd

pause Yes...you did this already.