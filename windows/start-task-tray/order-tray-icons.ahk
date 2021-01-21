#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases
#Warn ; Enable every type of warning; show each warning in a message box
#SingleInstance Force ; Skips the dialog box and replaces the old instance automatically, which is similar in effect to the Reload command
SendMode Input ; Recommended for new scripts due to its superior speed and reliability
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory
#Include %A_ScriptDir% ; Change the working directory used by all subsequent occurrences of #Include and FileInstall. SetWorkingDir has no effect on #Include because #Include is processed before the script begins executing.

if not A_IsAdmin
{
    Run, *RunAs "%A_ScriptFullPath%" /restart
    ExitApp
}

programTitle = Rearrange tray icons
TrayTip, % programTitle, Running

#Include, lib\TrayIcon.ahk

MsgBox, Make sure the mouse is over the left-most tray icon and press Enter

CoordMode, Mouse, Screen
MouseGetPos, trayX, trayY
originalTrayIconCount := TrayIcon_GetInfo().MaxIndex()

volumeIconPercentage := 33
SoundGet, originalVolume
SoundSet, % volumeIconPercentage

order := []
order.Push({ property: "tooltip", value: volumeIconPercentage . "%" }) ; Volume
order.Push({ property: "tooltip", value: "Internet access" })
order.Push({ property: "msgid", value: "27021597764224201" }) ; Power
order.Push({ property: "process", value: "SecurityHealthSystray.exe" })
order.Push({ property: "tooltip", value: "Bluetooth Devices" })
order.Push({ property: "process", value: "igfxEM.exe" })
order.Push({ property: "process", value: "OneDrive.exe" })
order.Push({ property: "process", value: "Everything.exe" })
order.Push({ property: "tooltip", value: "SnapX" })
order.Push({ property: "tooltip", value: "Ben.ahk" })
order.Push({ property: "process", value: "LCore.exe" })
order.Push({ property: "process", value: "Docker Desktop.exe" })
order.Push({ property: "process", value: "steam.exe" })
order.Push({ property: "process", value: "openvpn-gui.exe" })
order.Push({ property: "process", value: "slack.exe" })
order.Push({ property: "process", value: "Zoom.exe" })

Loop, % order.MaxIndex()
{
    orderItem := order[A_Index]
    trayIcons := TrayIcon_GetInfo()
    Loop, % trayIcons.MaxIndex()
    {
        trayIcon := trayIcons[A_Index]
        if InStr(trayIcon[orderItem.property], orderItem.value)
        {
            MoveTrayIcon(trayIcon.idx, trayX, trayY, originalTrayIconCount)
        }
    }
}

Loop, % order.MaxIndex() ; circuit breaker if icon moving is not working
{
    trayIcons := TrayIcon_GetInfo()
    unprocessedTrayIcon := trayIcons[trayIcons.MaxIndex()]
    if InStr(unprocessedTrayIcon.tooltip, volumeIconPercentage . "%")
    {
        break
    }
    MoveTrayIcon(unprocessedTrayIcon.idx, trayX, trayY, originalTrayIconCount)
}

SoundSet, % originalVolume
TrayTip, % programTitle, Finished

MoveTrayIcon(idx, originalTrayX, trayY, originalTrayIconCount)
{
    local
    ; TrayIcon_Move(trayIcon.idx, 0) ; This is not persisted through reboots, so do manual mouse clicks
    trayX := originalTrayX + 32 * (originalTrayIconCount - TrayIcon_GetInfo().MaxIndex()) ; handle new icons appearing while we're sorting
    MouseClick, Left, trayX + idx * 32, trayY, 1, 5, D
    MouseClick, Left, trayX, trayY, 1, 5, U
}
