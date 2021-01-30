if (!(Configured $forKids)) {
    Block "Store > Settings > App updates > Update apps automatically = Off" {
        New-Item "HKLM:\Software\Policies\Microsoft\WindowsStore" -ErrorAction Ignore
        Set-ItemProperty "HKLM:\Software\Policies\Microsoft\WindowsStore" -Name AutoDownload -Value 2
    }
}
