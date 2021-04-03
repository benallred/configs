FirstRunBlock "Devices > Printers & scanners > Add a printer or scanner > The printer that I want isn't listed" {
    if (!(Configured $forHome)) {
        Write-ManualStep "Select a shared printer by name = \\{Server}\{Printer}"
        rundll32 printui.dll PrintUIEntry /im
        WaitWhileProcess rundll32
    }
}
Block "Devices > Touchpad > Taps > Press the lower right corner of the touchpad to right-click = Off" {
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PrecisionTouchPad" -Name RightClickZoneEnabled -Value 0
} -RequiresReboot
Block "Devices > Touchpad > Three-finger gestures > Taps = Middle mouse button" {
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PrecisionTouchPad" -Name ThreeFingerTapEnabled -Value 4
} -RequiresReboot
Block "Devices > Touchpad > Four-finger gestures" {
    Write-Output "Devices > Touchpad > Four-finger gestures > Swipes = Custom"
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PrecisionTouchPad" -Name FourFingerSlideEnabled -Value 0xffff
    Write-Output "Devices > Touchpad > Related settings > Advanced gesture configuration > Configure your four finger gestures > Up = Volume up"
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PrecisionTouchPad" -Name FourFingerUp -Value 16
    Write-Output "Devices > Touchpad > Related settings > Advanced gesture configuration > Configure your four finger gestures > Down = Volume down"
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PrecisionTouchPad" -Name FourFingerDown -Value 17
    Write-Output "Devices > Touchpad > Related settings > Advanced gesture configuration > Configure your four finger gestures > Left = Next track"
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PrecisionTouchPad" -Name FourFingerLeft -Value 14
    Write-Output "Devices > Touchpad > Related settings > Advanced gesture configuration > Configure your four finger gestures > Right = Previous track"
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PrecisionTouchPad" -Name FourFingerRight -Value 15
    Write-Output "Devices > Touchpad > Four-finger gestures > Taps = Play/pause"
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PrecisionTouchPad" -Name FourFingerTapEnabled -Value 3
} -RequiresReboot
