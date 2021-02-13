function UninstallBlock([string]$AppName) {
    Block "Uninstall Appx package $AppName" {
        Get-AppxPackage $AppName | Remove-AppxPackage
        sleep -s 2 # not a big deal, but when the uninstalls are run so quickly, the PowerShell progress messages don't get cleaned up
    } {
        !(Get-AppxPackage $AppName)
    }
}

FirstRunBlock "Configure OneNote" {
    Write-ManualStep "Start OneNote notebooks syncing"
    start onenote:
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

UninstallBlock Microsoft.BingWeather
UninstallBlock Microsoft.GetHelp
UninstallBlock Microsoft.Getstarted # Tips
UninstallBlock Microsoft.OneConnect # Mobile Plans
UninstallBlock Microsoft.MicrosoftSolitaireCollection
UninstallBlock Microsoft.WindowsFeedbackHub
UninstallBlock Microsoft.MicrosoftOfficeHub
UninstallBlock Microsoft.WindowsMaps
UninstallBlock SpotifyAB.SpotifyMusic
