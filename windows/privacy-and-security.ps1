Block "Privacy & security > For developers > Change settings to allow remote connections to this computer > Show settings > Allow Remote Assistance connections to this computer = Off" {
    Set-RegistryValue "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name fAllowToGetHelp -Value 0
    Disable-NetFirewallRule -DisplayGroup "Remote Assistance"
}
