#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases
#Warn ; Enable every type of warning; show each warning in a message box
#SingleInstance Force ; Skips the dialog box and replaces the old instance automatically, which is similar in effect to the Reload command
SendMode Input ; Recommended for new scripts due to its superior speed and reliability
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory
#Include %A_ScriptDir% ; Change the working directory used by all subsequent occurrences of #Include and FileInstall. SetWorkingDir has no effect on #Include because #Include is processed before the script begins executing.

; #=Win; ^=Ctrl; +=Shift; !=Alt

if not A_IsAdmin
{
    Run, *RunAs "%A_ScriptFullPath%" /restart
    ExitApp
}

programTitle = AHK Template
TrayTip, % programTitle, Loaded
