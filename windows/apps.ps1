function UninstallBlock([string]$AppName) {
    Block "Uninstall Appx package $AppName" {
        Get-AppxPackage $AppName | Remove-AppxPackage
    } {
        !(Get-AppxPackage $AppName)
    }
}

FirstRunBlock "Configure OneNote" {
    Write-ManualStep "Start OneNote notebooks syncing"
    start onenote:
}

FirstRunBlock "Connect phone" {
    Write-ManualStep "Connect phone"
    start ms-phone:
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
