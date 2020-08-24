# ms-settings: URI scheme reference
# https://docs.microsoft.com/en-us/windows/uwp/launch-resume/launch-settings-app#ms-settings-uri-scheme-reference

Block "Rename computer" {
    Write-ManualStep
    Rename-Computer -NewName (Read-Host "Set computer name to")
} {
    $env:ComputerName -notlike 'desktop-*'
} -RequiresReboot
Block "Disable UAC" {
    & "$PSScriptRoot\Disable UAC.ps1"
}
FirstRunBlock "Add Microsoft account" {
    Write-ManualStep "Sign in with a Microsoft account instead"
    start ms-settings:yourinfo
}
Block "Control Panel > View by = Small icons" {
    TestPathOrNewItem "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel"
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name AllItemsIconView -Value 1
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name StartupPage -Value 1
}
Block "Control Panel > System > Remote settings > Allow Remote Assistance connections to this computer = Off" {
    Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name fAllowToGetHelp -Value 0
    Disable-NetFirewallRule -DisplayGroup "Remote Assistance"
}
Block "Clock" {
    Set-TimeZone "Mountain Standard Time"
    function SetAdditionalClock([int]$ClockNumber, [string]$DisplayName, [string]$TimeZoneId) {
        TestPathOrNewItem "HKCU:\Control Panel\TimeDate\AdditionalClocks\$ClockNumber"
        Set-ItemProperty "HKCU:\Control Panel\TimeDate\AdditionalClocks\$ClockNumber" -Name Enable -Value 1
        Set-ItemProperty "HKCU:\Control Panel\TimeDate\AdditionalClocks\$ClockNumber" -Name DisplayName -Value $DisplayName
        Set-ItemProperty "HKCU:\Control Panel\TimeDate\AdditionalClocks\$ClockNumber" -Name TzRegKeyName -Value $TimeZoneId
    }
    SetAdditionalClock 1 "UTC" "UTC"
    SetAdditionalClock 2 "Korea" "Korea Standard Time"
}
& $PSScriptRoot\desktop.ps1
& $PSScriptRoot\store.ps1
& $PSScriptRoot\explorer.ps1
& $PSScriptRoot\file-handlers.ps1
& $PSScriptRoot\personalization.ps1
& $PSScriptRoot\apps.ps1
& $PSScriptRoot\ease-of-access.ps1
& $PSScriptRoot\windows-features.ps1
FirstRunBlock "Set sign-in options" {
    Write-ManualStep "Windows Hello"
    start ms-settings:signinoptions
}
