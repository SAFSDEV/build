c:
cd \sqarepos\ddengine\datastorej
set oldpath=%PATH%

@REM set path=%PATH%;c:\j2sdk1.4.2_05\bin
set path=%PATH%;C:\Program Files\Java\jdk1.7.0_40\bin

javadoc -d ./javadoc -tag example:cm:"Example:" -sourcepath . -classpath .;classes;c:/staf/bin/jstaf.jar @javadocmodelfiles.txt

cd .\javadoc

del index.html

pause CTRL-C to abort pscp push to SAFSDEV, any key to continue...
pscp -r * ***REMOVED***@shell.sourceforge.net:/home/project-web/safsdev/htdocs/doc/

set path=oldpath
