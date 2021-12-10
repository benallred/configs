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

FirstRunBlock "Configure Mail" {
    ConfigureNotifications Mail
}

UninstallBlock Microsoft.BingNews_8wekyb3d8bbwe
UninstallBlock Microsoft.BingWeather_8wekyb3d8bbwe
UninstallBlock Microsoft.GetHelp_8wekyb3d8bbwe
UninstallBlock Microsoft.Getstarted_8wekyb3d8bbwe # Tips
UninstallBlock Microsoft.MicrosoftOfficeHub_8wekyb3d8bbwe
UninstallBlock Microsoft.MicrosoftSolitaireCollection_8wekyb3d8bbwe
UninstallBlock Microsoft.SkypeApp_kzf8qxf38zg5c
UninstallBlock Microsoft.WindowsFeedbackHub_8wekyb3d8bbwe
UninstallBlock Microsoft.WindowsMaps_8wekyb3d8bbwe
UninstallBlock Disney.37853FC22B2CE_6rarf9sa4v8jt # Disney+
UninstallBlock SpotifyAB.SpotifyMusic_zpdnekdrzrea0
