Block "Include web results in Start menu search = Off" {
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name CortanaConsent -Value 0
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name BingSearchEnabled -Value 0
    # Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name ConnectedSearchUseWeb -Value 0
    # Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name DisableWebSearch -Value 1

    #[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings]
    #"SafeSearchMode" = dword:00000002
}
