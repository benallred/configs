Block "System > Multitasking > Alt + Tab > Pressing Alt + Tab shows = Open windows only" {
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" MultiTaskingAltTabFilter 3
} -RequiresReboot
