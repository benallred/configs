Block "Personalization > Colors > Choose your color = Dark" {
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name AppsUseLightTheme -Value 0
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name SystemUsesLightTheme -Value 0
}
Block "Personalization > Colors > Windows colors = Seafoam teal (4, 4)" {
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\DWM" -Name AccentColor -Value 4287070979
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\DWM" -Name ColorizationAfterglow -Value 3288564615
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\DWM" -Name ColorizationColor -Value 3288564615
}
Block "Personalization > Lock screen > Get fun facts, tips, and more from Windows and Cortana on your lock screen = Off" {
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name RotatingLockScreenOverlayEnabled -Value 0
}
Block "Personalization > Lock screen > Screen saver settings > Screen saver = (None)" {
    Remove-ItemProperty "HKCU:\Control Panel\Desktop" -Name SCRNSAVE.EXE -ErrorAction Ignore
}
Block "Personalization > Lock screen > Screen saver settings > Wait = 10 minutes" {
    Set-ItemProperty "HKCU:\Control Panel\Desktop" -Name ScreenSaveTimeOut -Value 600
}
Block "Personalization > Lock screen > Screen saver settings > On resume, display logon screen = On" {
    Set-ItemProperty "HKCU:\Control Panel\Desktop" -Name ScreenSaverIsSecure -Value 1
}
Block "Personalization > Start > Show most used apps = Off" {
    TestPathOrNewItem "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name NoStartMenuMFUprogramsList -Value 1
}
Block "Personalization > Start > Show suggestions occasionally in Start = Off" {
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name SubscribedContent-338388Enabled -Value 0
}