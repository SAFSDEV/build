@ECHO off

REM =============================================================================================
REM Purpose:
REM   This script is supposed to push "modified source code" to a playpen location and
REM   invoke JENKINS job SeleniumPlus_Development_Debug to make build with latest source
REM   code plus files from playpen.
REM
REM Parameter:
REM   PlaypenLoc                a network path of the playpen location, WRITABLE by you
REM                             and READABLE by the build machine, such as \\huanghe\home\username\S1234567
REM   Debug                     whatever if provided then show the debug message
REM
REM Prerequisite:
REM   1. The GIT (2.7.4 or above) should have been installed
REM   2. The GIT_HOME environment should be set as the GIT installation folder
REM   3. New files (source file, jar file) should be added into the GIT stage area, otherwise
REM      they will not be counted.
REM
REM Example:
REM   playpen_build.bat \\huanghe\home\username\S1234567
REM   playpen_build.bat \\huanghe\home\username\S1234567 debug
REM
REM Note:
REM   This script should run in the SAFS Core repository
REM   1. Run the command "git clone https://github.com/SAFSDEV/Core", 
REM      we will have a "SAFS Core Project" in the Core directory.
REM   2. Then, we copy this batch script to Core directory.
REM   3. Then we modify/delete/add some source codes.
REM      For the new source codes, we need to use 'git add' 
REM      to add them into git stage area so the script will take them in count.
REM      DO NOT commit anything to you local repository, otherwise they will be ignored.
REM   4. Finally, run this batch with our own playpen location, an example as below:
REM      playpen_build.bat \\huanghe\home\username\S1234567
REM   
REM   User could modify this script to set PLAYPEN_LOCATION_PREFIX, then only a simple
REM   defect number is en as argument. 
REM   1. Modify script as below:
REM      SET PLAYPEN_LOCATION_PREFIX=\\huanghe\home\username\
REM   2. Then simply call as below:
REM      playpen_build.bat S1234567
REM      playpen_build.bat S1234567 debug
REM ===============================================================================================

SETLOCAL ENABLEDELAYEDEXPANSION
SET MY_NAME=playpen_build.bat
SET JENKINS_HOST=http://***REMOVED***
SET JENKINS_PORT=81
SET JENKINS_JOB=SeleniumPlus_Development_Debug
SET JENKINS_TOKEN=JLWEILAFJELWONBHGHAWHANGKWOAHTNWHAOTOQPZNJG
SET REQUEST_PATH=/jenkins/job/%JENKINS_JOB%/buildWithParameters
SET JENKINS_REQUEST=%JENKINS_HOST%:%JENKINS_PORT%%REQUEST_PATH%
SET SRC_LOCATION=src
SET MODIFIEDFILE_SUMMARY=modified_files_summary.txt
REM Define PLAYPEN_LOCATION_PREFIX so that only a simple "defect number" is enough as argument.
REM SET PLAYPEN_LOCATION_PREFIX=\\huanghe\home\username\

REM Check the environment GIT_HOME
IF NOT DEFINED GIT_HOME (
    ECHO Abort.
    ECHO PLEASE set environment GIT_HOME and assign "the GIT installation folder" to it.
    ECHO Git could be downloaded from https://git-scm.com/download/win
    GOTO :USAGE  
) ELSE (
    SET CURL="%GIT_HOME%\usr\bin\curl.exe"
    SET USE_OLD_CURL=TRUE
)

IF NOT EXIST %CURL% (
    SET CURL="%GIT_HOME%\mingw32\bin\curl.exe"
    SET USE_OLD_CURL=FALSE
)

REM Get input parameters
SET PLAYPEN_LOCATION=%1
SHIFT
SET DEBUG=%1

IF NOT DEFINED PLAYPEN_LOCATION (
    ECHO Abort.
    ECHO Parameter PLAYPEN_LOCATION is missing, please provide it, such as \\***REMOVED***\public\safs_playpen
    ECHO It should be a network directory, which is WRITABLE by you and READABLE by others.
    GOTO :USAGE  
)

IF DEFINED PLAYPEN_LOCATION_PREFIX (
    IF DEFINED DEBUG ECHO Add prefix %PLAYPEN_LOCATION_PREFIX%" to %PLAYPEN_LOCATION%
    SET PLAYPEN_LOCATION=%PLAYPEN_LOCATION_PREFIX%%PLAYPEN_LOCATION%
)

ECHO GIT_HOME is "%GIT_HOME%"
ECHO PLAYPEN_LOCATION is "%PLAYPEN_LOCATION%", source codes will be copied there.
Echo.

REM Clean the PLAYPEN if it exists.
IF EXIST %PLAYPEN_LOCATION% (
    FOR /D %%p IN ("%PLAYPEN_LOCATION%\*") DO (
        IF DEFINED DEBUG ECHO RD "%%p" /S /Q
        RD "%%p" /S /Q
    )
    IF DEFINED DEBUG ECHO ERASE %PLAYPEN_LOCATION%\* /F /Q
    ERASE "%PLAYPEN_LOCATION%\*" /F /Q
)

SET MODIFIEDFILES_SUMMARY_FILE=%PLAYPEN_LOCATION%\%MODIFIEDFILE_SUMMARY%

REM Then, we use the 'git status' to get the modified files, which will be uploaded to PLAYPEN
FOR /F "usebackq tokens=1,2* " %%i IN (`git status --short`) DO (
    SET Modified_File=%%j
    REM replace the slash by back-slash
    SET Modified_File=!Modified_File:/=\!
    REM strip the prefix "src\", as the destination build folder "source\common" contains directly java source code without that prefix.
    SET Modified_File_Without_Src=!Modified_File:%SRC_LOCATION%\=!

    SET OPERATION=NONE
    IF [%%i]==[M] SET OPERATION=ADD
    IF [%%i]==[A] SET OPERATION=ADD
    IF [%%i]==[MM] SET OPERATION=ADD
    IF [%%i]==[AM] SET OPERATION=ADD
    IF [%%i]==[D] SET OPERATION=DELETE
    IF DEFINED DEBUG ECHO Git status %%i -- !OPERATION! !Modified_File!

    IF [!OPERATION!]==[ADD] (
        IF DEFINED DEBUG ECHO ... %systemroot%\system32\xcopy /c /y /q /z !Modified_File! %PLAYPEN_LOCATION%\!Modified_File_Without_Src!
        ECHO F | %systemroot%\system32\xcopy /c /y /q /z !Modified_File! %PLAYPEN_LOCATION%\!Modified_File_Without_Src!
        ECHO !Modified_File_Without_Src! >> %MODIFIEDFILES_SUMMARY_FILE%
    )
    
    IF [!OPERATION!]==[DELETE] (
        IF DEFINED DEBUG ECHO TODO NEED A WAY TO DELETE FILE !Modified_File! FROM build location "workspace\source\common"
    )
)

IF EXIST %MODIFIEDFILES_SUMMARY_FILE% (
    REM call Jenkins job SeleniumPlus_Development_Debug, it is a post request
    IF DEFINED DEBUG ECHO %CURL% -d "token=%JENKINS_TOKEN%&delay=0sec&safs.playpen.location=%PLAYPEN_LOCATION%" "%JENKINS_REQUEST%"
    IF [%USE_OLD_CURL%]==[TRUE] (
        REM For older version of curl.exe, we have to add \\ in front of %PLAYPEN_LOCATION%, one "back slash" will be eaten, the leading \\ will be parsed as \
        SET PLAYPEN_LOCATION=\\%PLAYPEN_LOCATION%
    )
    %CURL% -d "token=%JENKINS_TOKEN%&delay=0sec&safs.playpen.location=%PLAYPEN_LOCATION%" "%JENKINS_REQUEST%"
    
    ECHO.
    ECHO Please check %MODIFIEDFILES_SUMMARY_FILE% to get a summary of modified files.
    ECHO You might need to wait a few minutes for the termination of Jenkins job %JENKINS_JOB% at %JENKINS_HOST%:%JENKINS_PORT%
) ELSE (
    Echo There is NO modified/added/deleted files, we will not trigger the Jenkins job %JENKINS_JOB%.
)

GOTO :END

:USAGE
ECHO.
ECHO ==================================================================
ECHO Usage:
ECHO %MY_NAME% PLAYPEN_LOCATION [debug]
ECHO.
ECHO Example:
ECHO %MY_NAME% \\huanghe\home\username\S1234567
ECHO %MY_NAME% \\huanghe\home\username\S1234567 debug
ECHO ==================================================================

:END

ENDLOCAL
