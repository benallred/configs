function UninstallBlock([string]$AppName) {
    Block "Uninstall Appx package $AppName" {
        winget uninstall $AppName
    } {
        !(winget list $AppName | sls $AppName)
    }
}

FirstRunBlock "Clean up items on desktop" {
    DeleteDesktopShortcut "Microsoft Edge"
}

if (!(Configured $forKids)) {
    FirstRunBlock "Connect phone" {
        Write-ManualStep "Connect phone"
        start ms-phone:
        ConfigureNotifications "Messages (via Your Phone)"
    }
}

UninstallBlock Microsoft.549981C3F5F10_8wekyb3d8bbwe # Cortana
UninstallBlock Microsoft.BingNews_8wekyb3d8bbwe
UninstallBlock Microsoft.BingWeather_8wekyb3d8bbwe
UninstallBlock Microsoft.GetHelp_8wekyb3d8bbwe
UninstallBlock Microsoft.Getstarted_8wekyb3d8bbwe # Tips
UninstallBlock Microsoft.MicrosoftOfficeHub_8wekyb3d8bbwe
UninstallBlock Microsoft.MicrosoftSolitaireCollection_8wekyb3d8bbwe
UninstallBlock Microsoft.SkypeApp_kzf8qxf38zg5c
UninstallBlock microsoft.windowscommunicationsapps_8wekyb3d8bbwe # Mail and Calendar
UninstallBlock Microsoft.WindowsFeedbackHub_8wekyb3d8bbwe
UninstallBlock Microsoft.WindowsMaps_8wekyb3d8bbwe
UninstallBlock Disney.37853FC22B2CE_6rarf9sa4v8jt # Disney+
UninstallBlock SpotifyAB.SpotifyMusic_zpdnekdrzrea0

if (Configured $forKids) {
    UninstallBlock MicrosoftTeams_8wekyb3d8bbwe
}
else {
    Block "Teams > Settings > General > Auto-start Teams = Off" {
        Set-RegistryValue "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\MicrosoftTeams_8wekyb3d8bbwe\TeamsStartupTask" State 0
    }
}
