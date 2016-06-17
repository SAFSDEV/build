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
cd \sqarepos\ddengine\datastorej\classes

SET JRE="%SELENIUM_PLUS%\Java\bin"

SET JARFILE=seleniumplus.jar
SET SELENIUMLIBS=C:\SeleniumPlus\libs
SET SELENIUMUPDATE=C:\Public\SeleniumPlus\update\libs

:FILTERIMAGEGUI_JAR
%JRE%\jar cmf META-INF\MANIFEST.SPFILTERIMAGEGUI.MF SPFilterImageGUI.jar org\safs\image\filter\

:SELENIUM_PLUS_JAR
%JRE%\jar cmf META-INF\MANIFEST.SELENIUMPLUS.MF %JARFILE% org\safs\selenium\
%JRE%\jar uf %JARFILE% org\safs\autoit\ 
%JRE%\jar uf %JARFILE% org\safs\sockets\DebugListener.class org\safs\sockets\NamedListener.class
%JRE%\jar uf %JARFILE% org\safs\android\auto\lib\*Console*.class org\safs\android\auto\lib\Process2*.class
%JRE%\jar uf %JARFILE% org\safs\model\ 
%JRE%\jar uf %JARFILE% org\safs\custom\
%JRE%\jar uf %JARFILE% *.dat *ResourceBundle*.properties *ResourceBundle*.properties.txt  
%JRE%\jar uf %JARFILE% org\safs\*.class org\safs\*.dat
%JRE%\jar uf %JARFILE% org\safs\control\
%JRE%\jar uf %JARFILE% org\safs\custom\
%JRE%\jar uf %JARFILE% org\safs\image\
%JRE%\jar uf %JARFILE% org\safs\install\
%JRE%\jar uf %JARFILE% org\safs\jvmagent\
%JRE%\jar uf %JARFILE% org\safs\logging\
%JRE%\jar uf %JARFILE% org\safs\net\
%JRE%\jar uf %JARFILE% org\safs\natives\
%JRE%\jar uf %JARFILE% org\safs\reflect\
%JRE%\jar uf %JARFILE% org\safs\rest\
%JRE%\jar uf %JARFILE% org\safs\rmi\
%JRE%\jar uf %JARFILE% org\safs\robot\
%JRE%\jar uf %JARFILE% org\safs\staf\
%JRE%\jar uf %JARFILE% org\safs\text\
%JRE%\jar uf %JARFILE% org\safs\tools\
%JRE%\jar uf %JARFILE% org\slf4j\impl\
%JRE%\jar uf %JARFILE% org\w3c\tools\codec\
%JRE%\jar uf %JARFILE% org\safs\xml\
%JRE%\jar uf %JARFILE% com\sebuilder\interpreter\

cd \sqarepos\ddengine\datastorej

copy classes\SPFilterImageGUI.jar %SELENIUMLIBS%
copy classes\SPFilterImageGUI.jar %SELENIUMUPDATE%

%JRE%\jar uf classes\%JARFILE% org\safs\selenium\
%JRE%\jar uf classes\%JARFILE% org\safs\model\ 

copy classes\%JARFILE% %SELENIUMLIBS%
copy classes\%JARFILE% %SELENIUMUPDATE%

copy classes\safslogs.jar %SELENIUMLIBS%
copy classes\safslogs.jar %SELENIUMUPDATE%
copy classes\safsmaps.jar %SELENIUMLIBS%
copy classes\safsmaps.jar %SELENIUMUPDATE%
copy classes\safsvars.jar %SELENIUMLIBS%
copy classes\safsvars.jar %SELENIUMUPDATE%
copy classes\safsinput.jar %SELENIUMLIBS%
copy classes\safsinput.jar %SELENIUMUPDATE%
copy classes\safsupdate.jar %SELENIUMLIBS%
copy classes\safsupdate.jar %SELENIUMUPDATE%

pause Yes...you did this already.