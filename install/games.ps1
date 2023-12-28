InstallFromWingetBlock Valve.Steam {
    DeleteDesktopShortcut Steam
    Set-RegistryValue "HKCU:\Software\Valve\Steam" RememberPassword 1
    if (Configured $forWork) {
        RemoveStartupRegistryKey Steam
    }
    if (Configured $forHome) {
        Write-ManualStep "Set install location"
    }
}

if (Configured $forHome, $forKids) {
    Block "Install Battle.net" {
        Download-File https://www.battle.net/download/getInstallerForGame $env:tmp\Battle.net-Setup.exe
        $battleNetSettings = @{
            Client = @{
                AutoLogin = "true"
                Install   = @{
                    CreateDesktopShortcut = "false"
                }
            }
        }
        if (Configured $forHome) {
            $battleNetSettings.Client.Install.DefaultInstallPath = "D:/Installs/Blizzard"
        }
        New-Item $env:AppData\Battle.net -Type Directory
        ConvertTo-Json $battleNetSettings -Depth 10 | Set-Content $env:AppData\Battle.net\Battle.net.config
        . $env:tmp\Battle.net-Setup.exe
        Add-Type -AssemblyName System.Windows.Forms
        $monSize = [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize
        $battleNetUserSettings = @{
            User = @{
                Client = @{
                    Windows                    = @{
                        BrowserMainWindow = @{
                            WindowPosition = "@Point($(($monSize.Width - 1000) / 2) $(($monSize.Height - 640) / 2))"
                            WindowSize     = "@Size(1000 640)"
                        }
                    }
                    HasSeenFirstTimeExperience = "true"
                    HideOnClose                = "false"
                    DisplayExitPrompt          = "false"
                    WindowNotificationShown    = "true"
                }
            }
        }
        WaitWhile { !(dir $env:AppData\Battle.net -Exclude Battle.net.config) } "Waiting for Battle.net user settings"
        $battleNetUserSettingsFilePath = dir $env:AppData\Battle.net -Exclude Battle.net.config
        Stop-Process -Name Battle.net
        ConvertTo-Json $battleNetUserSettings -Depth 10 | Set-Content $battleNetUserSettingsFilePath
        DeleteDesktopShortcut Battle.net
    } {
        Test-ProgramInstalled "Battle.net"
    }

    InstallFromWingetBlock Mojang.MinecraftLauncher
}

if (Configured $forHome) {
    InstallFromWingetBlock EpicGames.EpicGamesLauncher {
        DeleteDesktopShortcut "Epic Games Launcher"
        . "${env:ProgramFiles(x86)}\Epic Games\Launcher\Portal\Binaries\Win32\EpicGamesLauncher.exe"
        RemoveStartupRegistryKey EpicGamesLauncher
        $epicGamesSettingsFile = "$env:LocalAppData\EpicGamesLauncher\Saved\Config\Windows\GameUserSettings.ini"
            (Get-Content $epicGamesSettingsFile) -replace "\[Launcher\]", "`$0`nDefaultAppInstallLocation=D:\Installs\Epic Games" | Set-Content $epicGamesSettingsFile
            (Get-Content $epicGamesSettingsFile) -replace "\[.+?_General\]", "`$0`nNotificationsEnabled_Adverts=False" | Set-Content $epicGamesSettingsFile
    }

    InstallFromWingetBlock ElectronicArts.EADesktop {
        DeleteDesktopShortcut EA
        Add-Type -AssemblyName System.Windows.Forms
        $monSize = [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize
        WaitWhile { !(dir "$env:LocalAppData\Electronic Arts\EA Desktop" user_*.ini) } "Waiting for EA Desktop user settings"
        Stop-Process -Name EADesktop
        WaitWhileProcess EADesktop
        $script:eaDesktopSettings = Get-Content (dir "$env:LocalAppData\Electronic Arts\EA Desktop" user_*.ini)
        function AddOrUpdateSetting($setting, $value) {
            if ($script:eaDesktopSettings -like "*$setting*") {
                $script:eaDesktopSettings = $script:eaDesktopSettings -replace "$setting.+", "$setting=$value"
            }
            else {
                $script:eaDesktopSettings += "$setting=$value"
            }
        }
        AddOrUpdateSetting "user.windowsizewidth" 1441 # > 1440 for friends pane to not collapse
        AddOrUpdateSetting "user.windowsizeheight" 900
        AddOrUpdateSetting "user.windowposx" (($monSize.Width - 1440) / 2)
        AddOrUpdateSetting "user.windowposy" (($monSize.Height - 900) / 2)
        AddOrUpdateSetting "user.automaticcontentupdates" 1
        AddOrUpdateSetting "user.downloadinplacedir" "D:\Installs\EA Games\"
        Set-Content (dir "$env:LocalAppData\Electronic Arts\EA Desktop" user_*.ini) $script:eaDesktopSettings
    }
}
