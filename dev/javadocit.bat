c:
cd \sqarepos\ddengine\datastorej
set oldpath=%PATH%

@REM set path=%PATH%;c:\j2sdk1.4.2_14\bin
set path=%PATH%;%SELENIUM_PLUS%\Java\bin
set DROIDMESSENGER=C:\SQARepos\DDEngine\SAFSACCSProject
set DROIDENGINE=C:\SQARepos\DDEngine\SAFSDroidAutomation

javadoc -d -J-Xms1024M -J-Xmx1024M ./javadoc -tag example:cm:"Example:" -package -sourcepath .;%DROIDMESSENGER%/src;%DROIDMESSENGER%/gen;%DROIDENGINE%/src;%DROIDENGINE%/gen -classpath .;classes;c:/staf/bin/jstaf.jar;%DROIDMESSENGER%/bin/classes;%DROIDENGINE%/bin/classes;%DROIDENGINE%/libs/robotium-solo-5.0.1 @javadocfiles.txt

cd .\javadoc

del index.html

pause CTRL-C to abort pscp push to SAFSDEV, any key to continue...
pscp -r * sascanagl,safsdev@web.sourceforge.net:/home/project-web/safsdev/htdocs/doc/

set path=oldpath
