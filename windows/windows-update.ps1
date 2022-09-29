Block "Windows Update > Advanced options > Notify me when a restart is required to finish updating = On" {
    Set-RegistryValue "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name RestartNotificationsAllowed2 -Value 1
}
