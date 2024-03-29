# ms-settings: URI scheme reference
# https://docs.microsoft.com/en-us/windows/uwp/launch-resume/launch-settings-app#ms-settings-uri-scheme-reference
# https://ss64.com/nt/syntax-settings.html

Block "Rename computer" {
    Write-ManualStep
    Rename-Computer -NewName (Read-Host "Set computer name to")
} {
    $env:ComputerName -notlike 'desktop-*' -and $env:ComputerName -notlike 'laptop-*'
} -RequiresReboot
Block "Disable UAC" {
    & "$PSScriptRoot\Disable UAC.ps1"
}
FirstRunBlock "Configure OneDrive" {
    Write-ManualStep "Start OneDrive syncing"
    . "$env:LocalAppData\Microsoft\OneDrive\OneDrive.exe"
    ConfigureNotifications Microsoft.SkyDrive.Desktop ShowInActionCenter $false
}
Block "Control Panel > View by = Small icons" {
    Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name AllItemsIconView -Value 1
    Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name StartupPage -Value 1
}
Block "Configure Registry" {
    Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit\Favorites" "Notifications\Settings" "Computer\HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings"
}
& $PSScriptRoot\desktop.ps1
& $PSScriptRoot\explorer.ps1
& $PSScriptRoot\file-handlers.ps1
& $PSScriptRoot\system.ps1
& $PSScriptRoot\devices.ps1
& $PSScriptRoot\personalization.ps1
& $PSScriptRoot\apps.ps1
& $PSScriptRoot\accounts.ps1
& $PSScriptRoot\time-and-language.ps1
& $PSScriptRoot\accessibility.ps1
& $PSScriptRoot\privacy-and-security.ps1
& $PSScriptRoot\windows-update.ps1
& $PSScriptRoot\windows-features.ps1
FirstRunBlock "Set sign-in options" {
    Write-ManualStep "Windows Hello"
    start ms-settings:signinoptions
}
