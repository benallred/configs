Block "Personalization > Colors > Choose your mode = Dark" {
    Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name AppsUseLightTheme -Value 0
    Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name SystemUsesLightTheme -Value 0
}
if (!(Configured $forKids)) {
    Block "Personalization > Colors > Accent color = Seafoam teal" {
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\DWM" -Name AccentColor -Value 4287070979
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\DWM" -Name ColorizationAfterglow -Value 3288564615
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\DWM" -Name ColorizationColor -Value 3288564615
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\DWM" -Name ColorizationGlassAttribute -Value 1
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent" -Name AccentColorMenu -Value 4287070979
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent" -Name AccentPalette -Value ([byte[]]@(124, 251, 252, 0, 33, 246, 250, 0, 4, 173, 178, 0, 3, 131, 135, 0, 3, 114, 118, 0, 2, 75, 78, 0, 1, 40, 42, 0, 239, 105, 80, 0))
        Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent" -Name StartColorMenu -Value 4285952515
    }
}
Block "Personalization > Lock screen > Personalize your lock screen > Get fun facts, tips, tricks, and more on your lock screen = Off" {
    Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name RotatingLockScreenOverlayEnabled -Value 0
}
# Block "Personalization > Lock screen > Screen saver > Screen saver = (None)" {
#     Remove-ItemProperty "HKCU:\Control Panel\Desktop" -Name SCRNSAVE.EXE -ErrorAction Ignore
# }
# Block "Personalization > Lock screen > Screen saver > Wait = 10 minutes" {
#     Set-RegistryValue "HKCU:\Control Panel\Desktop" -Name ScreenSaveTimeOut -Value 600
# }
# Block "Personalization > Lock screen > Screen saver > On resume, display logon screen = On" {
#     Set-RegistryValue "HKCU:\Control Panel\Desktop" -Name ScreenSaverIsSecure -Value 1
# }
Block "Personalization > Start > Show most used apps = Off" {
    Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoStartMenuMFUprogramsList -Value 1
}
Block "Personalization > Taskbar > Taskbar items > Search = Off" {
    Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name SearchboxTaskbarMode -Value 0
}
Block "Personalization > Taskbar > Taskbar items > Task view = Off" {
    Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name ShowTaskViewButton -Value 0
}
Block "Personalization > Taskbar > Taskbar items > Widgets = Off" {
    Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name TaskbarDa -Value 0
}
Block "Personalization > Taskbar > Taskbar items > Chat = Off" {
    Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name TaskbarMn -Value 0
}
Block "Personalization > Taskbar > Taskbar behaviors > When using multiple displays, show my taskbar apps on = Taskbar where window is open" {
    Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name MMTaskbarMode -Value 2
} -RequiresReboot
