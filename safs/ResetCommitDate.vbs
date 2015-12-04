'=======================================================================================
'==========  Purpose: After clone a repository, the file's last modified date   ========
'==========           will be the moment of cloning, this script could reset    ========
'==========           the last modified date to the moment the file's last      ========
'==========           committed time.                                           ========
'==========  Prerequisite: GitBash SHOULD have been installed.                  ========
'==========  Usage:        ResetCommitDate.vbs <folder1> [folder2] ...          ========
'==========  History:                                                           ========
'==========          DEC 01, 2012 (LeiWang) CREATED                             ========
'==========          DEC 02, 2012 (LeiWang) Fix dead loop problem.              ========
'=======================================================================================

Dim shell, env, fso, shellApp
Dim newline
Dim scriptName, rootFolder
' debug boolean, if true, the debug message will be shown.
' silent boolean, if true, the debug message will be wrote to log "Event Viewer->Windows Logs->Application".
'                 otherwise, will be shown in popup dialog.
'                 This only take effect when debug is set to true.
Dim debug, silent
' visitedFolders string array, hold the visited folders to avoid a dead loop
Dim visitedFolders()
Dim TEMPFILE
Dim j

Set shell = WScript.CreateObject("WScript.Shell")
Set env = shell.Environment("SYSTEM")
Set fso = WScript.CreateObject("Scripting.FileSystemObject")
Set shellApp = CreateObject("Shell.Application")

On Error Resume Next
newline = chr(13) & chr(10)
TEMPFILE= fso.GetSpecialFolder(2) & "\seplus.resetdata.temp"
debug = false
silent = true
scriptName = "ResetCommitDate.vbs"

If WScript.Arguments.Count = 0 Then
    Log 1, "Please provide at the lease one folder name as parameter."
Else
	For j = 0 to WScript.Arguments.Count-1
		rootFolder = fso.GetAbsolutePathName(WScript.Arguments(j))
		Log 4, "Parameter(" & j & ")='" & WScript.Arguments(j) & newline & "' Resetting 'last modified date' for files under folder " & rootFolder
		ReDim visitedFolders(0)
		ChangeLastModifiedDate rootFolder	
	Next
End If

Set shell = nothing
Set env = nothing
Set fso   = nothing
Set shellApp = nothing
'==========   End of Script  ====================================

'*****************************************************************************
'* Purpose: Reset file's last modified time to its git last commit time.
'* Parameter:
'*   folder, the folder in a git repository under which the file's "last modified time" will be reset.
'*           it should be given as an absolute path
'*****************************************************************************
Function ChangeLastModifiedDate(folder)
	On Error Resume Next
	
	Dim folderObj, items, item, visited, visitedFolder, i
	
	Set folderObj = shellApp.NameSpace(folder)

	If (not folderObj is nothing) Then
		Set items = folderObj.Items
	
		If (not items is nothing) Then
			showItems folderObj
			
			For i = 0 to items.Count-1
				Set item = items.Item(i)
				Log 4, "visiting : " & folder & "(" & i & ")=" & item.Path
				
				'.zip file will be considered as a folder, but we don't want that
				If item.IsFolder And Not StringContainsIgnoreCase(item.Path, ".zip") Then
					visited = False
					For Each visitedFolder in visitedFolders
						If item.Path=visitedFolder Then
							visited = True
							Exit For
						End If
					Next
					
					If Not visited Then
						Log 4, "Drill down folder: " & item.Path & newline & " index=" & i & newline & " count=" & items.Count
						ReDim Preserve visitedFolders(UBound(visitedFolders)+1)
						visitedFolders(UBound(visitedFolders)) = item.Path
						ChangeLastModifiedDate(item.Path)
					Else
						Log 2, "You have visited: " & item.Path & newline & " index=" & i & newline & " count=" & items.Count
						showItems folderObj
					End If
				Else
					Log 4, "Before reset: " & item.Path & " last modified date is " & item.ModifyDate
					item.ModifyDate = GetGitLastCommitDate(item.Path)
					Log 4, "After reset: " & item.Path & " last modified date is " & item.ModifyDate
				End If
				
				Set item = nothing
			Next
			Set items = nothing
		End If
		Set folderObj = nothing
	Else
		Log 1, "File '"&folder&"' is not a valid folder name."
	End If

	If Err.Number <> 0 Then
		Log 1, "Error in ChangeLastModifiedDate: " & Err.Description
		Err.Clear
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
	''return git last commit iso date such as 2015-09-23 17:17:44 -0400
	
	''Exec command "git log ..." and retrieve the commit date from the output
	''The only problem is that Exec will show the teminal window for each execution
	Log 4, "Executing shell command: " & newline & cmd
	Set exec = shell.Exec(cmd)
	''extract stdout and stderr
    Do While exec.Status = 0
        GetGitLastCommitDate = readall(exec)
		''WScript.Sleep(1)
	Loop
	''GetGitLastCommitDate will be 'STDOUT:\r\n2015-09-23 17:17:44 -0400
	GetGitLastCommitDate = Mid(GetGitLastCommitDate, 10, 19) '2015-09-23 17:17:44
	
	'Dim MyFile
	'cmd = cmd & " > " & TEMPFILE
	'Log 4, "Executing shell command: " & cmd
	'shell.Run cmd, 0, True
	'Set MyFile = fso.OpenTextFile(TEMPFILE, 1)
	'Do While MyFile.AtEndOfStream <> True
	'	GetGitLastCommitDate = GetGitLastCommitDate & MyFile.ReadLine & newline
	'Loop
	'MyFile.Close
	'Set MyFile = nothing
	
	''GetGitLastCommitDate will be '2015-09-23 17:17:44 -0400
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
'*   forceShow,  boolean, if true then debug message will be shown in popup
'* Global Variable:
'*   debug,  boolean, if false then this method will do nothing
'*   silent, boolean, if true the write the log message to system
'*                    log "Event Viewer->Windows Logs->Application".
'*                    otherwise, show the message in a popup window.
'*   scriptName, string, the script name to prefix each log message for easy trace.
'*****************************************************************************
Function Log(eventLevel, message, forceShow)
	Dim localMsg, popupType
	
	On Error Resume Next
	
    If debug Or forceShow Then
		If silent And Not forceShow Then
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

'*****************************************************************************
'* Purpose: Show all children of a folder.
'* Parameter:
'*   folderObj, Folder, the Folder object got by CreateObject("Shell.Application").NameSpace(folder)
'*****************************************************************************
Function showItems(folderObj)
	Dim children, items, i
	
	Set items = folderObj.Items
	For i = 0 to items.Count-1
		children = children & newline & items.Item(i).Path
	Next

	Set items = nothing
	Log 4, folderObj.title & " contains: " & children
End Function

'*****************************************************************************
'* Purpose: Check if one string contains another case-insensitively
'* Parameter:
'*   Str1, string, the string to contain
'*   Str2, string, the string to be contained
'*****************************************************************************
Function StringContainsIgnoreCase(Str1, Str2)
	Dim foundPosition

	foundPosition = InStr(1, Str1, Str2, 1) 'vbTextCompare
    If IsNull(foundPosition) or foundPosition=0 Then
        StringContainsIgnoreCase = False
    Else
        StringContainsIgnoreCase = True
    End If
	
End Function