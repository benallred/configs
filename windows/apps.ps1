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

FirstRunBlock "Configure OneNote" {
    Write-ManualStep "Start OneNote notebooks syncing"
    start "shell:AppsFolder\$(Get-StartApps "OneNote for Windows 10" | select -ExpandProperty AppId)"
    WaitWhileProcess onenoteim
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

UninstallBlock Microsoft.BingWeather_8wekyb3d8bbwe
UninstallBlock Microsoft.GetHelp_8wekyb3d8bbwe
UninstallBlock Microsoft.Getstarted_8wekyb3d8bbwe # Tips
UninstallBlock Microsoft.MicrosoftSolitaireCollection_8wekyb3d8bbwe
UninstallBlock Microsoft.WindowsFeedbackHub_8wekyb3d8bbwe
UninstallBlock Microsoft.MicrosoftOfficeHub_8wekyb3d8bbwe
UninstallBlock Microsoft.WindowsMaps_8wekyb3d8bbwe
