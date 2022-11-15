Block "File Explorer > Options > General > Open File Explorer to = This PC" {
    Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name LaunchTo -Value 1
}
if (!(Configured $forKids)) {
    Block "File Explorer > Options > View > Advanced settings > Files and Folders > Hidden files and folders = Show hidden files, folders, and drives" {
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name Hidden -Value 1
    }
}
Block "File Explorer > Options > View > Advanced settings > Files and Folders > Hide empty drives = Off" {
    Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name HideDrivesWithNoMedia -Value 0
}
Block "File Explorer > Options > View > Advanced settings > Files and Folders > Hide extensions for known file types = Off" {
    Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name HideFileExt -Value 0
}
Block "File Explorer > Options > View > Advanced settings > Files and Folders > Hide folder merge conflicts = Off" {
    Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name HideMergeConflicts -Value 0
}
if (!(Configured $forKids)) {
    Block "File Explorer > Options > View > Advanced settings > Files and Folders > Hide protected operating system files (Recommended) = Off" {
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name ShowSuperHidden -Value 1
    } -RequiresReboot
}
Block "File Explorer > Options > View > Advanced settings > Files and Folders > Restore previous folder windows at logon = On" {
    Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name PersistBrowsers -Value 1
}
Block "File Explorer > Options > View > Advanced settings > Files and Folders > Show sync provider notifications = Off" {
    Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name ShowSyncProviderNotifications -Value 0
}
Block "File Explorer > Options > View > Advanced settings > Navigation pane > Expand to open folder = On" {
    Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name NavPaneExpandToCurrentFolder -Value 1
}
Block "File Explorer > Options > View > Advanced settings > Navigation pane > Show all folders = On" {
    Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name NavPaneShowAllFolders -Value 1
}
Block "Hide Quick access in Navigation pane" {
    Set-RegistryValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name HubMode -Value 1
}
Block "Hide Libraries in Navigation pane" {
    Set-RegistryValue "HKCU:\Software\Classes\CLSID\{031E4825-7B94-4dc3-B131-E946B44C8DD5}\ShellFolder" -Name Attributes -Value 0xb090010d
} -RequiresReboot
Block "Hide Control Panel in Navigation pane" {
    Set-RegistryValue "HKCU:\Software\Classes\CLSID\{26EE0668-A00A-44D7-9371-BEB064C98683}\ShellFolder" -Name Attributes -Value 0xa0900004
} -RequiresReboot
Block "Internet Options > Advanced > Browsing > Use inline AutoComplete = On" {
    Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoComplete" -Name "Append Completion" -Value "yes"
}
Block "Hide Folders Section in This PC" {
    & "$PSScriptRoot\Hide Folders Section in This PC.ps1"
}
Block "shell:sendto VS Code" {
    New-Shortcut -Target "$env:LocalAppData\Programs\Microsoft VS Code\Code.exe" -Link "$((New-Object -ComObject WScript.Shell).SpecialFolders.Item("sendto"))\nCode.lnk"
}
