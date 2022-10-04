#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases
#Warn ; Enable every type of warning; show each warning in a message box
#SingleInstance Force ; Skips the dialog box and replaces the old instance automatically, which is similar in effect to the Reload command
SendMode Input ; Recommended for new scripts due to its superior speed and reliability
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory
#Include %A_ScriptDir% ; Change the working directory used by all subsequent occurrences of #Include and FileInstall. SetWorkingDir has no effect on #Include because #Include is processed before the script begins executing.

EnsureAdminOrRestart()

programTitle = AHK Template
iconFilePath := "shell32.dll"
iconNumber := 44

RunOnSystemStart(programTitle, iconFilePath, iconNumber)

Menu, Tray, Icon, % iconFilePath, % iconNumber, 1
TrayTip, % programTitle, Loaded

EnsureAdminOrRestart()
{
    if not A_IsAdmin
    {
        Run, *RunAs "%A_ScriptFullPath%" /restart
        ExitApp
    }
}

RunOnSystemStart(linkName, iconFilePath, iconNumber)
{
    startupLinkFile := A_Startup "\" linkName ".lnk"
    IfNotExist, % startupLinkFile
    {
        FileCreateShortcut, % A_ScriptFullPath, % startupLinkFile, % A_ScriptDir, , , % iconFilePath, , % iconNumber
    }
}

; #=Win; ^=Ctrl; +=Shift; !=Alt
