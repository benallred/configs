Block "Time & Language > Date & time > Time zone = (UTC-07:00) Mountain Time (US & Canada)" {
    Set-TimeZone "Mountain Standard Time"
}
Block "Time & Language > Date & time > Add clocks for different time zones" {
    function SetAdditionalClock([int]$ClockNumber, [string]$DisplayName, [string]$TimeZoneId) {
        Set-RegistryValue "HKCU:\Control Panel\TimeDate\AdditionalClocks\$ClockNumber" -Name Enable -Value 1
        Set-RegistryValue "HKCU:\Control Panel\TimeDate\AdditionalClocks\$ClockNumber" -Name DisplayName -Value $DisplayName
        Set-RegistryValue "HKCU:\Control Panel\TimeDate\AdditionalClocks\$ClockNumber" -Name TzRegKeyName -Value $TimeZoneId
    }
    SetAdditionalClock 1 "UTC" "UTC"
    SetAdditionalClock 2 "Korea" "Korea Standard Time"
}
Block "Time & Language > Language > Keyboard > Input language hot keys > Between input languages > Change Key Sequence > Switch Input Language = Not Assigned" {
    Set-RegistryValue "HKCU:\Keyboard Layout\Toggle" -Name "Language Hotkey" -Value "3"
    Set-RegistryValue "HKCU:\Keyboard Layout\Toggle" -Name "Layout Hotkey" -Value "3"
}
