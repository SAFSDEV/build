'*  Name:       antExecAsync.vbs
'*  Purpose:    Wrapper script to run an executable detached in the 
'*              background from Ant's <exec> task.  This works by running the executable
'*              using the Windows Scripting Host WshShell.Run method which doesn't copy
'*              the standard filehandles stdin, stdout and stderr. Ant finds them closed
'*              and doesn't wait for the program to exit.
'*  Note:       This script is converted from antRunAsyn.js provided by Jekins.
'* 
'*  requirements:
'*    Windows Scripting Host 1.0 or better.  This is included with Windows 
'*    98/Me/2000/XP.  Users of Windows 95 or Windows NT 4.0 need to download
'*    and install WSH support from 
'*    http:'* msdn.microsoft.com/scripting/.
'* 
'*  usage:
'*  <exec executable="cscript.exe">
'*    <env key="ANTRUN_TITLE" value="Title for Window" />  <!-- optional -->
'*    <env key="ANTRUN_OUTPUT" value="output.log" />  <!-- optional -->
'*    <arg value="// NoLogo" />
'*    <arg value="antExecAsync.vbs" />  <!-- this script -->
'*    <arg value="real executable" />
'*    <arg value="parameter" />
'*  </exec>

Dim shell, ProcessEnv, OS, isWindowsNT
Dim exeStr, arg, windowStyle, title, outputFile
Dim i, q

Set shell = WScript.CreateObject("WScript.Shell")
Set ProcessEnv = shell.Environment("PROCESS")

exeStr = "%comspec% /c"
arg = ""
windowStyle = 1
windowTitle = ProcessEnv("ANTRUN_TITLE")
outputFile = ProcessEnv("ANTRUN_OUTPUT")
OS = ProcessEnv("OS")
isWindowsNT = (OS = "Windows_NT")

q         = chr(34)   'double quote

'*  On Windows NT/2000/XP, specify a title for the window.  If the environment
'*  variable ANTRUN_TITLE is specified, that will be used instead of a default.
if isWindowsNT then
  if windowTitle = "" then
     windowTitle = "Ant - " & WScript.Arguments(0)
  end if
  exeStr = exeStr & "title " & windowTitle & " &&"
end if

'*  Loop through arguments quoting ones with spaces
for i=0 to WScript.Arguments.count()-1
  arg = WScript.Arguments(i)
  WScript.Echo(">>>>>>>>>>>>>>>" & arg)
  if InStr(arg, " ") > 0 then
    '* double-quote the paramter if it contains sapce
    exeStr = exeStr & " " & q & arg & q
  else
    exeStr = exeStr & " " & arg
  end if
next

'*  If the environment variable ANTRUN_OUTPUT was specified, redirect
'*  output to that file.
if outputFile <> "" then
  windowStyle = 7  '* new window is minimized
  exeStr = exeStr & " > " & q & outputFile & q
  if isWindowsNT then
    exeStr = exeStr & " 2>&1"
  end if
end if

WScript.Echo("shell.Run " & exeStr & ", " & windowStyle & ", false ")
shell.Run exeStr, windowStyle, false