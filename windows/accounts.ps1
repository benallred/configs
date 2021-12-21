Block "Accounts > Sign-in options > Use my sign-in info to automatically finish setting up after an update = Off" {
    Set-RegistryValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name DisableAutomaticRestartSignOn -Value 1
}
