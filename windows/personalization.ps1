Block "Personalization > Colors > Choose your mode = Dark" {
    Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name AppsUseLightTheme -Value 0
    Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name SystemUsesLightTheme -Value 0
}
# if (!(Configured $forKids)) {
#     Block "Personalization > Colors > Accent color = Seafoam teal (4, 4)" {
#         Set-RegistryValue "HKCU:\Software\Microsoft\Windows\DWM" -Name AccentColor -Value 4287070979
#         Set-RegistryValue "HKCU:\Software\Microsoft\Windows\DWM" -Name ColorizationAfterglow -Value 3288564615
#         Set-RegistryValue "HKCU:\Software\Microsoft\Windows\DWM" -Name ColorizationColor -Value 3288564615
#         Set-RegistryValue "HKCU:\Software\Microsoft\Windows\DWM" -Name EnableWindowColorization -Value 1
#     }
# }
# Block "Personalization > Lock screen > Get fun facts, tips, and more from Windows and Cortana on your lock screen = Off" {
#     Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name RotatingLockScreenOverlayEnabled -Value 0
# }
# Block "Personalization > Lock screen > Screen saver settings > Screen saver = (None)" {
#     Remove-ItemProperty "HKCU:\Control Panel\Desktop" -Name SCRNSAVE.EXE -ErrorAction Ignore
# }
# Block "Personalization > Lock screen > Screen saver settings > Wait = 10 minutes" {
#     Set-RegistryValue "HKCU:\Control Panel\Desktop" -Name ScreenSaveTimeOut -Value 600
# }
# Block "Personalization > Lock screen > Screen saver settings > On resume, display logon screen = On" {
#     Set-RegistryValue "HKCU:\Control Panel\Desktop" -Name ScreenSaverIsSecure -Value 1
# }
Block "Personalization > Start > Show most used apps = Off" {
    Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoStartMenuMFUprogramsList -Value 1
}
# Block "Personalization > Start > Show suggestions occasionally in Start = Off" {
#     Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name SubscribedContent-338388Enabled -Value 0
# }
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
# Block "Personalization > Taskbar > Lock the taskbar = On" {
#     Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name TaskbarSizeMove -Value 0
# }
# Block "Personalization > Taskbar > Taskbar behaviors > Automatically hide the taskbar in tablet mode = On" {
#     Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name TaskbarAutoHideInTabletMode -Value 1
# }
# Block "Personalization > Taskbar > Use small taskbar buttons = On" {
#     Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name TaskbarSmallIcons -Value 1
# } -RequiresReboot
# Block "Personalization > Taskbar > Combine taskbar buttons = Never" {
#     Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name TaskbarGlomLevel -Value 2
# } -RequiresReboot
# Block "Personalization > Taskbar > Notification area > Select which icons appear on the taskbar > Always show all icons in the notification area = On" {
#     Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name EnableAutoTray -Value 0
# } -RequiresReboot
# Block "Personalization > Taskbar > Taskbar behaviors > Multiple displays > Show taskbar buttons on = Taskbar where window is open" {
#     Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name MMTaskbarMode -Value 2
# } -RequiresReboot
# Block "Personalization > Taskbar > Multiple displays > Combine buttons on other taskbars = Never" {
#     Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name MMTaskbarGlomLevel -Value 2
# } -RequiresReboot
