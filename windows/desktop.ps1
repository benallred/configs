Block "Desktop > View > Small icons" {
    Set-RegistryValue "HKCU:\Software\Microsoft\Windows\Shell\Bags\1\Desktop" -Name IconSize -Value 32
} -RequiresReboot
Block "Recycle Bin > Properties > Display delete confirmation dialog = On" {
    Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name ConfirmFileDelete -Value 1
}
