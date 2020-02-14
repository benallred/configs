Block "Backup Registry" {
    & $PSScriptRoot\backup.ps1
}
Block "Rename computer" {
    Rename-Computer -NewName (Read-Host "Set computer name to")
} {
    $env:ComputerName -notlike 'desktop-*'
} -RequiresReboot
Block "Disable UAC" {
    & "$PSScriptRoot\Disable UAC.ps1"
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
& $PSScriptRoot\ease-of-access.ps1
& $PSScriptRoot\personalization.ps1
& $PSScriptRoot\windows-features.ps1
