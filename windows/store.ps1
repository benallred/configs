if (!(Configured $forKids)) {
    Block "Store > Settings > App updates > Update apps automatically = Off" {
        Set-RegistryValue "HKLM:\Software\Policies\Microsoft\WindowsStore" -Name AutoDownload -Value 2
    }
}
