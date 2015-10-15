;REM =============================================
;REM Assumes project is on Windows C: Drive.
;REM Assumes compiled classes are output into a
;REM "<projectroot>\classes" subdirectory.
;REM 
;REM All non-built assets like *.properties, 
;REM *.dat, and META-INF manifests must also 
;REM exist in the <projectroot>\classes hierarchy.
;REM =============================================

C:
cd \sqarepos\ddengine\datastorej

SET JRE="%SELENIUM_PLUS%\Java\bin"

SET EXTSAFSROOT=C:\SAFS
SET SAFSEXPLIBS=C:\SAFSEXP\lib
SET SAFSEXPINSTALL=C:\SAFSEXP\install
SET EXTSAFSLIBS=C:\SAFS\lib
SET EXTMESSENGERLIBS=C:\SQARepos\DDEngine\SAFSACCSProject\libs
SET EXTDROIDLIBS=C:\SQARepos\DDEngine\SAFSDroidAutomation\libs
SET EXTROBOTIUMRCDIST=C:\RobotiumRemoteControl
SET EXTROBOTIUMRCDISTLIBS=C:\RobotiumRemoteControl\SoloRemoteControl\libs
SET EXTROBOTIUMRCDISTMESSENGER=C:\RobotiumRemoteControl\SAFSTCPMessenger\libs
SET EXTROBOTIUMRCDISTRUNNER=C:\RobotiumRemoteControl\SAFSTestRunner\libs


;REM ======================================================
;REM Select the appropriate statement for tools on this box
;REM 
;REM SET XDE=FT  if Rational Functional Tester is installed
;REM SET XDE=XDE if RobotJ or XDE Tester is installed.
;REM 
;REM ======================================================
SET XDE=FT
;REM SET XDE=XDE

;REM =========================================
;REM Nothing but maintenance below this line
;REM =========================================

;REM =========================================
;REM Copy JSAFS Model sourcecode for the JAR.
;REM =========================================
xcopy /E /Y org\safs\model\*.* classes\org\safs\model\

;REM ===========================================================
;REM NO LONGER Copy Android Remote Control Sourcefiles (too big)
;REM ===========================================================
;REM copy /Y org\safs\sockets\*.* classes\org\safs\sockets\
;REM copy /Y com\jayway\android\robotium\remotecontrol\solo\*.* classes\com\jayway\android\robotium\remotecontrol\solo\

copy /Y *.dat classes\
copy /Y *.properties classes\
copy /Y *.properties.txt classes\
Copy /Y TestScript.java classes\
copy /Y org\safs\*.dat classes\org\safs\
;REM copy /Y org\safs\abbot\*.dat classes\org\safs\abbot\
copy /Y org\safs\jvmagent\*.dat classes\org\safs\jvmagent\
copy /Y org\safs\rational\*.dat classes\org\safs\rational\
copy /Y org\safs\rational\*.properties classes\org\safs\rational\
copy /Y org\safs\rational\ft\*.dat classes\org\safs\rational\ft\
copy /Y org\safs\rational\flex\custom\*.dat classes\org\safs\rational\flex\custom\
copy /Y org\safs\selenium\*.js classes\org\safs\selenium\
copy /Y org\safs\staf\service\*.properties classes\org\safs\staf\service\
Copy /Y resources\TestScriptHelper.java classes\resources\


;REM =========================================
;REM Build RMI Bridge Stubs as necessary.
;REM =========================================
%JRE%\rmic -classpath classes -d classes org.safs.rmi.engine.ServerImpl
%JRE%\rmic -classpath classes -d classes org.safs.rmi.engine.AgentImpl
%JRE%\rmic -classpath classes -d classes org.safs.selenium.rmi.agent.SeleniumAgent
%JRE%\rmic -classpath classes -d classes org.safs.selenium.rmi.server.SeleniumServer

cd classes

;REM =========================================
;REM A painless but required RFT dependency.
;REM =========================================
copy META-INF\DatastoreDefinition.rftdsd resources\DatastoreDefinition.rftdsd

copy org\safs\staf\service\map\SAFSAppMapService.class STAF-INF\classes\org\safs\staf\service\map\SAFSAppMapService.class
copy org\safs\staf\service\map\SAFSAppMapService3.class STAF-INF\classes\org\safs\staf\service\map\SAFSAppMapService3.class
copy org\safs\staf\service\var\SAFSVariableService.class STAF-INF\classes\org\safs\staf\service\var\SAFSVariableService.class
copy org\safs\staf\service\var\SAFSVariableService3.class STAF-INF\classes\org\safs\staf\service\var\SAFSVariableService3.class
copy org\safs\staf\service\input\SAFSInputService.class STAF-INF\classes\org\safs\staf\service\input\SAFSInputService.class
copy org\safs\staf\service\input\SAFSInputService3.class STAF-INF\classes\org\safs\staf\service\input\SAFSInputService3.class
copy org\safs\staf\service\logging\v2\SAFSLoggingService.class STAF-INF\classes\org\safs\staf\service\logging\v2\SAFSLoggingService.class
copy org\safs\staf\service\logging\v3\SAFSLoggingService3.class STAF-INF\classes\org\safs\staf\service\logging\v3\SAFSLoggingService3.class

@REM :SAFSABBOT_JAR
@REM %JRE%\jar cmf META-INF\MANIFEST.ABBOT.MF safsabbot.jar org\safs\abbot\
@REM copy safsabbot.jar %EXTSAFSLIBS%
@REM copy safsabbot.jar %SAFSEXPLIBS%

:SAFSDROID_JAR
%JRE%\jar cmf META-INF\MANIFEST.DROID.MF safsdroid.jar org\safs\android\ 
%JRE%\jar uf safsdroid.jar org\safs\JavaSockets*.* 
%JRE%\jar uf safsdroid.jar org\safs\SocketTestRecordHelper.* 
copy safsdroid.jar %EXTSAFSLIBS%
copy safsdroid.jar %SAFSEXPLIBS%

:SAFSAUTOANDROID_JAR (also used by Robotium Remote Control)
%JRE%\jar cf safsautoandroid.jar org\safs\android\auto\
%JRE%\jar uf safsautoandroid.jar org\safs\IndependantLog.* 
%JRE%\jar uf safsautoandroid.jar org\safs\sockets\NamedListener.* 
%JRE%\jar uf safsautoandroid.jar org\safs\sockets\DebugListener.* 
%JRE%\jar uf safsautoandroid.jar org\safs\tools\CaseInsensitiveFile.* 
%JRE%\jar uf safsautoandroid.jar org\safs\tools\GenericProcessMonitor.* 
%JRE%\jar uf safsautoandroid.jar org\safs\tools\consoles\GenericProcessConsole.* 
%JRE%\jar uf safsautoandroid.jar org\safs\tools\consoles\GenericProcessCapture.*
%JRE%\jar uf safsautoandroid.jar org\w3c\tools\codec\  
copy safsautoandroid.jar %EXTSAFSLIBS%
copy safsautoandroid.jar %SAFSEXPLIBS%
copy safsautoandroid.jar %EXTROBOTIUMRCDISTLIBS%

:SAFSUPDATE_JAR 
%JRE%\jar cmf META-INF\MANIFEST.LIBRARYUPDATE.MF safsupdate.jar org\safs\IndependantLog.* org\safs\sockets\NamedListener.* org\safs\sockets\DebugListener.* org\safs\StringUtils.* org\safs\SAFSException.* org\safs\install\LibraryUpdate*.* org\safs\install\ProgressIndicator*.* org\safs\text\FileUtilities.* org\safs\tools\CaseInsensitiveFile.* org\safs\tools\MainClass.* org\safs\tools\RuntimeDataInterface.* org\safs\tools\stringutils\StringUtilities.*
copy safsupdate.jar %EXTSAFSLIBS%
copy safsupdate.jar %SAFSEXPLIBS%

:SAFSSELENIUM_JAR
%JRE%\jar cmf META-INF\MANIFEST.SELENIUM.MF safsselenium.jar org\safs\selenium\
copy safsselenium.jar %EXTSAFSLIBS%
copy safsselenium.jar %SAFSEXPLIBS%

:SAFSSOCKETS_JAR
%JRE%\jar cf safssockets.jar org\safs\sockets\
copy safssockets.jar %EXTSAFSLIBS%
copy safssockets.jar %SAFSEXPLIBS%
copy safssockets.jar %EXTDROIDLIBS%
copy safssockets.jar %EXTMESSENGERLIBS%
copy safssockets.jar %EXTROBOTIUMRCDISTLIBS%
copy safssockets.jar %EXTROBOTIUMRCDISTMESSENGER%
copy safssockets.jar %EXTROBOTIUMRCDISTRUNNER%

:SAFS_REMOTECONTROL_JAR
%JRE%\jar cmf META-INF\MANIFEST.REMOTECONTROL.MF safs-remotecontrol.jar com\jayway\android\robotium\remotecontrol\solo\
%JRE%\jar uf safs-remotecontrol.jar com\jayway\android\robotium\remotecontrol\MyTest.*
%JRE%\jar uf safs-remotecontrol.jar com\robotium\solo\
%JRE%\jar uf safs-remotecontrol.jar org\safs\android\remotecontrol\
copy safs-remotecontrol.jar %EXTSAFSLIBS%
copy safs-remotecontrol.jar %SAFSEXPLIBS%
copy safs-remotecontrol.jar %EXTROBOTIUMRCDISTLIBS%

:ROBOTIUM_SERIALIZABLE_JAR
%JRE%\jar cf robotium-serializable.jar com\jayway\android\robotium\remotecontrol\*.class
copy robotium-serializable.jar %EXTSAFSLIBS%
copy robotium-serializable.jar %SAFSEXPLIBS%
copy robotium-serializable.jar %EXTDROIDLIBS%
copy robotium-serializable.jar %EXTROBOTIUMRCDISTLIBS%
copy robotium-serializable.jar %EXTROBOTIUMRCDISTRUNNER%

:ROBOTIUM_MESSAGES_JAR
%JRE%\jar cf robotium-messages.jar com\jayway\android\robotium\remotecontrol\solo\Message.*
%JRE%\jar uf robotium-messages.jar org\w3c\tools\codec\
copy robotium-messages.jar %EXTDROIDLIBS%
copy robotium-messages.jar %EXTROBOTIUMRCDISTLIBS%
copy robotium-messages.jar %EXTROBOTIUMRCDISTRUNNER%

:SAFS_MESSAGES_JAR
%JRE%\jar cf safs-messages.jar org\safs\android\remotecontrol\SAFSMessage.*
%JRE%\jar uf safs-messages.jar org\safs\text\FAILKEYS.* org\safs\text\GENKEYS.* org\safs\text\ResourceMessageInfo.*
%JRE%\jar uf safs-messages.jar org\safs\text\CaseInsensitiveHashtable.* org\safs\text\FileLineReader.* org\safs\text\INIFileReader.* org\safs\text\INIFileReader$*.*
copy safs-messages.jar %EXTDROIDLIBS%
copy safs-messages.jar %EXTROBOTIUMRCDISTRUNNER%

:SAFS_GUICLASSDATA_JAR
%JRE%\jar cf safs-guiclassdata.jar org\safs\GuiClassData.* org\safs\JavaConstant.* org\safs\IndependantLog.*
;REM
;REM CAUSES FAILED TEST RUNNER BUILDS: %JRE%\jar uf safs-guiclassdata.jar org\safs\sockets\DebugListener.* org\safs\sockets\NamedListener.*
;REM 
%JRE%\jar uf safs-guiclassdata.jar org\safs\jvmagent\AgentClassLoader.* org\safs\logging\AbstractLogFacility.*
%JRE%\jar uf safs-guiclassdata.jar org\safs\tools\drivers\DriverConstant.* org\safs\tools\CaseInsensitiveFile.*
copy safs-guiclassdata.jar %EXTDROIDLIBS%
copy safs-guiclassdata.jar %EXTROBOTIUMRCDISTRUNNER%

:SAFSIOS_JAR
%JRE%\jar cmf META-INF\MANIFEST.IOS.MF safsios.jar org\safs\ios\ 
copy safsios.jar %EXTSAFSLIBS%
copy safsios.jar %SAFSEXPLIBS%

:SAFSRATIONAL_FT_JAR
IF %XDE%==XDE GOTO :SAFSRATIONAL_XDE_JAR

;REM DO NOT INCLUDE SAS CUSTOM FLEX SUPPORT IN SAFSRATIONAL_FT.JAR
%JRE%\jar cmf META-INF\MANIFEST.FT.MF safsrational_ft.jar TestScript.* *.dat *ResourceBundle*.properties *ResourceBundle*.properties.txt resources\TestScrip*.* resources\DatastoreDefinition.rftdsd org\safs\rational\*.class org\safs\rational\*.dat org\safs\rational\*.properties  org\safs\rational\custom\ org\safs\rational\flex\*.class org\safs\rational\ft\  org\safs\rational\logging\   org\safs\rational\win\  org\safs\rational\wpf\
%JRE%\jar cmf META-INF\MANIFEST.GENERIC.MF safsrational_ft_enabler.jar resources\DatastoreDefinition.rftdsd org\safs\rational\ft\ 

;REM INCLUDE SAS CUSTOM FLEX SUPPORT IN SAFSRATIONAL_FT_CUSTOM.JAR
%JRE%\jar cf safsrational_ft_custom.jar org\safs\rational\flex\custom\
copy safsrational_ft.jar %EXTSAFSLIBS%
copy safsrational_ft_enabler.jar %EXTSAFSLIBS%
copy safsrational_ft_custom.jar %EXTSAFSLIBS%
copy safsrational_ft.jar %SAFSEXPLIBS%
copy safsrational_ft_enabler.jar %SAFSEXPLIBS%
copy safsrational_ft_custom.jar %SAFSEXPLIBS%
GOTO SAFSJREX_JAR

:SAFSRATIONAL_XDE_JAR
%JRE%\jar cmf META-INF\MANIFEST.XDE.MF safsrational_xde.jar TestScript.* *.dat *ResourceBundle*.properties *ResourceBundle*.properties.txt resources\TestScrip*.* resources\DatastoreDefinition.rftdsd org\safs\rational\ 
copy safsrational_xde.jar %EXTSAFSLIBS%
copy safsrational_xde.jar %SAFSEXPLIBS%


:SAFSJREX_JAR
;REM %JRE%\jar cmf META-INF\MANIFEST.JREX.MF safsjrex.jar org\safs\jrex\ 
;REM copy safsjrex.jar %EXTSAFSLIBS%
;REM copy safsjrex.jar %SAFSEXPLIBS%

:SAFSMODEL_JAR
%JRE%\jar cmf META-INF\MANIFEST.GENERIC.MF safsmodel.jar org\safs\model\ 
copy safsmodel.jar %EXTSAFSLIBS%
copy safsmodel.jar %SAFSEXPLIBS%

:FILTERIMAGEGUI_JAR
%JRE%\jar cmf META-INF\MANIFEST.FILTERIMAGEGUI.MF FilterImageGUI.jar org\safs\image\filter\
copy FilterImageGUI.jar %EXTSAFSLIBS%
copy FilterImageGUI.jar %SAFSEXPLIBS%

:SAFSCUST_JAR
%JRE%\jar cmf META-INF\MANIFEST.GENERIC.MF safscust.jar org\safs\custom\
copy safscust.jar %EXTSAFSLIBS%
copy safscust.jar %SAFSEXPLIBS%

:SAFSJVMAGENT_JAR
%JRE%\jar cmf META-INF\MANIFEST.JVMAGENT.MF safsjvmagent.jar safsjvmagent.properties org\safs\jvmagent\Bootstrap.*  org\safs\jvmagent\AgentClassLoader.* org\safs\jvmagent\Platform.*
copy safsjvmagent.jar %EXTSAFSLIBS%
copy safsjvmagent.jar %SAFSEXPLIBS%


:SAFS_JAR
%JRE%\jar cmf META-INF\MANIFEST.SAFS.MF safs.jar *.dat *ResourceBundle*.properties *ResourceBundle*.properties.txt  
%JRE%\jar uf safs.jar org\safs\*.class org\safs\*.dat

@REM %JRE%\jar uf safs.jar org\safs\abbot\

%JRE%\jar uf safs.jar org\safs\autoit\
%JRE%\jar uf safs.jar org\safs\control\
%JRE%\jar uf safs.jar org\safs\cukes\
%JRE%\jar uf safs.jar org\safs\custom\
%JRE%\jar uf safs.jar org\safs\image\
%JRE%\jar uf safs.jar org\safs\install\
%JRE%\jar uf safs.jar org\safs\jvmagent\
%JRE%\jar uf safs.jar org\safs\logging\

@REM %JRE%\jar uf safs.jar org\safs\model\

%JRE%\jar uf safs.jar org\safs\net\
%JRE%\jar uf safs.jar org\safs\natives\
%JRE%\jar uf safs.jar org\safs\reflect\
%JRE%\jar uf safs.jar org\safs\rmi\
%JRE%\jar uf safs.jar org\safs\robot\
%JRE%\jar uf safs.jar org\safs\sockets\
%JRE%\jar uf safs.jar org\safs\staf\
%JRE%\jar uf safs.jar org\safs\text\
%JRE%\jar uf safs.jar org\safs\tools\
%JRE%\jar uf safs.jar org\w3c\tools\codec\

@REM %JRE%\jar uf safs.jar org\safs\tools\counters\
@REM %JRE%\jar uf safs.jar org\safs\tools\data\
@REM %JRE%\jar uf safs.jar org\safs\tools\drivers\
@REM %JRE%\jar uf safs.jar org\safs\tools\engines\ 
@REM %JRE%\jar uf safs.jar org\safs\tools\expression\
@REM %JRE%\jar uf safs.jar org\safs\tools\input\
@REM %JRE%\jar uf safs.jar org\safs\tools\logs\
@REM %JRE%\jar uf safs.jar org\safs\tools\mail\
@REM %JRE%\jar uf safs.jar org\safs\tools\stacks\
@REM %JRE%\jar uf safs.jar org\safs\tools\status\
@REM %JRE%\jar uf safs.jar org\safs\tools\stringutils\
@REM %JRE%\jar uf safs.jar org\safs\tools\vars\

%JRE%\jar uf safs.jar org\safs\xml\
copy safs.jar %EXTSAFSLIBS%
copy safs.jar %SAFSEXPLIBS%


:SAFS_SERVICES
%JRE%\jar cmf STAF-INF\classes\META-INF\SAFSAppMapsManifest.mf safsmaps.jar STAF-INF\classes\org\safs\staf\service\map\SAFSAppMapService.class STAF-INF\classes\org\safs\staf\service\map\SAFSAppMapService3.class
%JRE%\jar cmf STAF-INF\classes\META-INF\SAFSVariablesManifest.mf safsvars.jar STAF-INF\classes\org\safs\staf\service\var\SAFSVariableService.class STAF-INF\classes\org\safs\staf\service\var\SAFSVariableService3.class
%JRE%\jar cmf STAF-INF\classes\META-INF\SAFSInputManifest.mf safsinput.jar STAF-INF\classes\org\safs\staf\service\input\SAFSInputService.class STAF-INF\classes\org\safs\staf\service\input\SAFSInputService3.class
%JRE%\jar cmf STAF-INF\classes\META-INF\SAFSLoggingManifest.mf safslogs.jar STAF-INF\classes\org\safs\staf\service\logging\v2\SAFSLoggingService.class STAF-INF\classes\org\safs\staf\service\logging\v3\SAFSLoggingService3.class
copy safslogs.jar %EXTSAFSLIBS%
copy safsmaps.jar %EXTSAFSLIBS%
copy safsvars.jar %EXTSAFSLIBS%
copy safsinput.jar %EXTSAFSLIBS%
copy safslogs.jar %SAFSEXPLIBS%
copy safsmaps.jar %SAFSEXPLIBS%
copy safsvars.jar %SAFSEXPLIBS%
copy safsinput.jar %SAFSEXPLIBS%

:SAFSINSTALL_JAR
%JRE%\jar cmf STAF-INF\classes\META-INF\SilentInstaller.mf safsinstall.jar org\safs\install\*.class
%JRE%\jar uf safsinstall.jar org\safs\natives\*.class org\safs\natives\win32\*.class
%JRE%\jar uf safsinstall.jar org\safs\text\FileUtilities.class org\safs\text\FileUtilitiesByThirdParty.class
%JRE%\jar uf safsinstall.jar org\safs\tools\CaseInsensitiveFile.class org\safs\tools\MainClass.class
%JRE%\jar uf safsinstall.jar org\safs\tools\consoles\Generic*.class org\safs\tools\consoles\ProcessCapture.class
%JRE%\jar uf safsinstall.jar org\safs\tools\stringutils\StringUtilities.class
%JRE%\jar uf safsinstall.jar org\safs\IndependantLog.class org\safs\SAFSException.class
%JRE%\jar uf safsinstall.jar org\safs\sockets\DebugListener.class org\safs\sockets\NamedListener.class
%JRE%\jar uf safsinstall.jar org\safs\android\auto\lib\*Console*.class org\safs\android\auto\lib\Process2*.class
copy safsinstall.jar %EXTSAFSLIBS%
copy safsinstall.jar %EXTSAFSROOT%
copy safsinstall.jar %SAFSEXPLIBS%
copy safsinstall.jar %SAFSEXPINSTALL%


:ROBOTIUMRCINSTALL_JAR
%JRE%\jar cmf STAF-INF\classes\META-INF\RobotiumInstaller.mf robotiumrcinstall.jar com\jayway\android\robotium\remotecontrol\install\*.class org\safs\install\ProgressIndicator.class
%JRE%\jar uf robotiumrcinstall.jar org\safs\text\FileUtilities.class
%JRE%\jar uf robotiumrcinstall.jar org\safs\tools\CaseInsensitiveFile.class org\safs\tools\MainClass.class
%JRE%\jar uf robotiumrcinstall.jar org\safs\tools\stringutils\StringUtilities.class org\safs\IndependantLog.class org\safs\SAFSException.class
%JRE%\jar uf robotiumrcinstall.jar org\safs\sockets\DebugListener.class org\safs\sockets\NamedListener.class
%JRE%\jar uf robotiumrcinstall.jar org\safs\android\auto\lib\*Console*.class org\safs\android\auto\lib\Process2*.class
%JRE%\jar uf robotiumrcinstall.jar org\safs\android\auto\lib\AntTool.class org\safs\android\auto\lib\AndroidTools.class 
copy robotiumrcinstall.jar %EXTROBOTIUMRCDIST%


:SAFSDEBUG_JAR
%JRE%\jar cf safsdebug.jar *.dat *.properties *.properties.txt org\safs\selenium\*.js
copy safsdebug.jar %EXTSAFSLIBS%
copy safsdebug.jar %SAFSEXPLIBS%

REM Creating ZIP of all SAFS JARS....
%JRE%\jar cf _safs-lib-update.zip  FilterImageGUI.jar robotium-messages.jar robotiumrcinstall.jar robotium-serializable.jar safs.jar safsabbot.jar safsautoandroid.jar safscust.jar safsdebug.jar safsdroid.jar safs-guiclassdata.jar safsinput.jar safsinstall.jar safsios.jar safsjvmagent.jar safslogs.jar safsmaps.jar safs-messages.jar safsmodel.jar safsrational_ft.jar safsrational_ft_custom.jar safsrational_ft_enabler.jar safs-remotecontrol.jar safsselenium.jar safssockets.jar safsupdate.jar safsvars.jar


pause Yes...you did this already.