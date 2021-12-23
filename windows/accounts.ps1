Block "Accounts > Sign-in options > Use my sign-in info to automatically finish setting up after an update = Off" {
    Set-RegistryValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name DisableAutomaticRestartSignOn -Value 1
}
Block "Accounts > Sign-in options > If you've been away, when should Windows require you to sign in again? = 15 minutes" {
    Set-RegistryValue "HKCU:\Control Panel\Desktop" -Name DelayLockInterval -Value 900
}
