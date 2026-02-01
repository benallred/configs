Block "Configure Edge" {
    DeleteDesktopShortcut "Microsoft Edge"
    DeleteDesktopShortcut "Personal - Edge"

    # https://learn.microsoft.com/en-us/deployedge/microsoft-edge-policies
    Set-RegistryValue "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name WebWidgetAllowed -Value 0
    Set-RegistryValue "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name HubsSidebarEnabled -Value 0
}

if (Configured $forHome, $forWork, $forTest) {
    FirstRunBlock "Connect phone" {
        Write-ManualStep "Connect phone"
        start ms-phone:
        ConfigureNotifications Microsoft.YourPhone_8wekyb3d8bbwe!YourPhoneMessages ShowInActionCenter $false
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
UninstallBlock Microsoft.Todos_8wekyb3d8bbwe
UninstallBlock Disney.37853FC22B2CE_6rarf9sa4v8jt # Disney+
UninstallBlock SpotifyAB.SpotifyMusic_zpdnekdrzrea0
UninstallBlock C27EB4BA.DropboxOEM_xbfy0k16fey96 # Dropbox promotion

if (Configured $forHtpc) {
    UninstallBlock MicrosoftTeams_8wekyb3d8bbwe
}
else {
    Block "Teams > Settings > General > Auto-start Teams = Off" {
        RemoveStartupRegistryKey Teams
    }
}
