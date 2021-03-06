# ms-settings: URI scheme reference
# https://docs.microsoft.com/en-us/windows/uwp/launch-resume/launch-settings-app#ms-settings-uri-scheme-reference

Block "Rename computer" {
    Write-ManualStep
    Rename-Computer -NewName (Read-Host "Set computer name to")
} {
    $env:ComputerName -notlike 'desktop-*' -and $env:ComputerName -notlike 'laptop-*'
} -RequiresReboot
Block "Disable UAC" {
    & "$PSScriptRoot\Disable UAC.ps1"
}
FirstRunBlock "Add Microsoft account" {
    Write-ManualStep "Sign in with a Microsoft account instead"
    start ms-settings:yourinfo
    WaitWhileProcess SystemSettings
}
FirstRunBlock "Configure OneDrive" {
    Write-ManualStep "Start OneDrive syncing"
    . "$env:LocalAppData\Microsoft\OneDrive\OneDrive.exe"
}
Block "Control Panel > View by = Small icons" {
    Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name AllItemsIconView -Value 1
    Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name StartupPage -Value 1
}
Block "Control Panel > System > Remote settings > Allow Remote Assistance connections to this computer = Off" {
    Set-RegistryValue "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name fAllowToGetHelp -Value 0
    Disable-NetFirewallRule -DisplayGroup "Remote Assistance"
}
& $PSScriptRoot\desktop.ps1
& $PSScriptRoot\store.ps1
& $PSScriptRoot\explorer.ps1
& $PSScriptRoot\file-handlers.ps1
& $PSScriptRoot\system.ps1
& $PSScriptRoot\devices.ps1
& $PSScriptRoot\personalization.ps1
& $PSScriptRoot\apps.ps1
& $PSScriptRoot\time-and-language.ps1
& $PSScriptRoot\ease-of-access.ps1
& $PSScriptRoot\windows-features.ps1
FirstRunBlock "Set sign-in options" {
    Write-ManualStep "Windows Hello"
    start ms-settings:signinoptions
}
