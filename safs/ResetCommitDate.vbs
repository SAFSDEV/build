'=======================================================================================
'==========  Purpose: After clone a repository, the file's last modified date   ========
'==========           will be the moment of cloning, this script could reset    ========
'==========           the last modified date to the moment the file's last      ========
'==========           committed time.                                           ========
'==========  Prerequisite: GitBash SHOULD have been installed.                  ========
'==========  Usage:        ResetCommitDate.vbs <folder1> [folder2] [folder3]    ========
'==========  History:                                                           ========
'==========          DEC 01, 2012 (LeiWang) CREATED                             ========
'=======================================================================================

Dim shell, env, fso, shellApp
Dim newline
Dim scriptName, rootFolder, debug, silent
Dim lastVisitedFolder

Set shell = WScript.CreateObject("WScript.Shell")
Set env = shell.Environment("SYSTEM")
Set fso = WScript.CreateObject("Scripting.FileSystemObject")
Set shellApp = CreateObject("Shell.Application")

On Error Resume Next
newline = chr(13) & chr(10)
TEMPFILE= fso.GetSpecialFolder(2) & "\seplus.resetdata.temp"
debug = false
silent = false
scriptName = "ResetCommitDate.vbs"

If WScript.Arguments.Count = 0 Then
    Log 1, "Please provide at the lease one folder name as parameter."
Else
	For i = 0 to WScript.Arguments.Count-1
		rootFolder = fso.GetAbsolutePathName(WScript.Arguments(i))
		Log 4, "Parameter(" & i & ")='" & WScript.Arguments(i) & newline & "' Resetting 'last modified date' for files under folder " & rootFolder
		ChangeLastModifiedDate rootFolder	
	Next
End If

Set shell = nothing
Set fso   = nothing
Set exec  = nothing
'==========   End of Script  ====================================

'*****************************************************************************
'* Purpose: Reset file's last modified time to its git last commit time.
'* Parameter:
'*   folder, the folder in a git repository under which the file's "last modified time" will be reset
'*           it should be given as absolute path
'*****************************************************************************
Function ChangeLastModifiedDate(folder)
	On Error Resume Next
	
	Set folderObj = shellApp.NameSpace(folder)

	If (not folderObj is nothing) Then
		Set items = folderObj.Items
	
		If (not items is nothing) Then
			For i = 0 to items.Count-1
				Set item = items.Item(i)
				If item.IsFolder And lastVisitedFolder<>item.Path Then
				    lastVisitedFolder = item.Path
					ChangeLastModifiedDate(item)
				Else
					Log 4, "Before reset: " & item.Path & " last modified date is " & item.ModifyDate
					item.ModifyDate = GetGitLastCommitDate(item.Path)
					Log 4, "After reset: " & item.Path & " last modified date is " & item.ModifyDate
				End If
			Next
		End If
	Else
		Log 1, "File '"&folder&"' is not a valid folder name."
	End If

End Function

'*****************************************************************************
'* Purpose: Get the file's git last commit date time.
'* Parameter:
'*   file, the file in a git repository
'* Return:
'*   the date time string in general format(the format depends on System setting)
'*****************************************************************************
Function GetGitLastCommitDate(file)
	Dim exec, cmd
	On Error Resume Next
	
	GetGitLastCommitDate = ""
	cmd = "git log --pretty=format:%cd -n 1 --date=iso " & file
	'return git last commit iso date such as 2015-09-23 17:17:44 -0400
	
	'Exec command "git log ..." and retrieve the commit date from the output
	'The only problem is that Exec will show the teminal window for each execution
	Log 4, "Executing shell command: " & newline & cmd
	Set exec = shell.Exec(cmd)
	'extract stdout and stderr
    Do While exec.Status = 0
        GetGitLastCommitDate = readall(exec)
		'WScript.Sleep(1)
	Loop
	'GetGitLastCommitDate will be 'STDOUT:\r\n2015-09-23 17:17:44 -0400
	GetGitLastCommitDate = Mid(GetGitLastCommitDate, 10, 19) '2015-09-23 17:17:44
	
	'cmd = cmd & " > " & TEMPFILE
	'Log 4, "Executing shell command: " & cmd
	'shell.Run cmd, 0, True
	'Set MyFile = fso.OpenTextFile(TEMPFILE, 1)
	'Do While MyFile.AtEndOfStream <> True
	'	GetGitLastCommitDate = GetGitLastCommitDate & MyFile.ReadLine & newline
	'Loop
	'MyFile.Close
	
	'GetGitLastCommitDate will be '2015-09-23 17:17:44 -0400
	'GetGitLastCommitDate = Mid(GetGitLastCommitDate, 1, 19) '2015-09-23 17:17:44
	'Log 4, GetGitLastCommitDate
	
	GetGitLastCommitDate = FormatDateTime(GetGitLastCommitDate,vbGeneralDate) '2015/09/23 17:17:44
	Log 4, file & " last modified date: " & GetGitLastCommitDate

	Set exec = nothing
End Function

'*****************************************************************************
'* ReadAll  Streams
'* Assumes a global new line mark named 'newline', newline = chr(13) & chr(10)
'*****************************************************************************
Function readall(exec)
	On Error Resume Next
    readall = ""
    if not exec.StdOut.AtEndOfStream then
        readall = "STDOUT:" & newline & exec.StdOut.ReadAll        
    end if

    if not exec.StdErr.AtEndOfStream then
        readall = readall &"STDERR:" & newline & exec.StdErr.ReadAll        
    end if
End Function

'*****************************************************************************
'* Purpose: Log message. Show the message in a popup window; Or write the message to system
'*          log "Event Viewer->Windows Logs->Application". It depends on the value of 
'*          a global variable 'silent'.
'* Parameter:
'*   eventLevel, int, the event level, refer to wscript LogEvent. 0 Success, 1 Error, 2 Warning, 4 Info
'*   message,    string, the message to log
'* Global Variable:
'*   debug,  boolean, if false then this method will do nothing
'*   silent, boolean, if true the write the log message to system
'*                    log "Event Viewer->Windows Logs->Application".
'*                    otherwise, show the message in a popup window.
'*****************************************************************************
Function Log(eventLevel, message)
	Dim localMsg, popupType
	
	On Error Resume Next
	
    If debug Then
		If silent Then
			localMsg = scriptName & ": " & message
			shell.LogEvent eventLevel, localMsg
		Else
			'localMsg = scriptName & ": " & message
			'WScript.Echo localMsg
			
			localMsg = message
			If eventLevel=0 Then
				popupType=0
			ElseIf eventLevel=1 Then
				popupType=16
			ElseIf eventLevel=2 Then
				popupType=48
			ElseIf eventLevel=4 Then
				popupType=64
			End If
			shell.Popup localMsg, 0, scriptName, popupType
		End If
	End If
	
End Function