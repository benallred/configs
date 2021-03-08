Block "Desktop > View > Small icons" {
    Set-RegistryValue "HKCU:\Software\Microsoft\Windows\Shell\Bags\1\Desktop" -Name IconSize -Value 32
} -RequiresReboot
Block "Taskbar > Search = Hidden" {
    Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name SearchboxTaskbarMode -Value 0
}
Block "Taskbar > Show Cortana button = Off" {
    Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name ShowCortanaButton -Value 0
}
Block "Taskbar > Show Windows Ink Workspace button = Off" {
    Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\PenWorkspace" -Name PenWorkspaceButtonDesiredVisibility -Value 0
}
