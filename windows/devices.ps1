if (!(Configured $forHome) -and !(Configured $forTest)) {
    FirstRunBlock "Bluetooth & devices > Printers & scanners > Add a printer or scanner > The printer that I want isn't listed" {
        Write-ManualStep "Select a shared printer by name = \\{Server}\{Printer}"
        rundll32 printui.dll PrintUIEntry /im
        WaitWhileProcess rundll32
    }
}
Block "Bluetooth & devices > Touchpad > Taps > Press the lower right corner of the touchpad to right-click = Off" {
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PrecisionTouchPad" -Name RightClickZoneEnabled -Value 0
} -RequiresReboot
Block "Bluetooth & devices > Touchpad > Three-finger gestures > Taps = Middle mouse button" {
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PrecisionTouchPad" -Name ThreeFingerTapEnabled -Value 4
} -RequiresReboot
Block "Bluetooth & devices > Touchpad > Four-finger gestures" {
    Write-Output "Bluetooth & devices > Touchpad > Four-finger gestures > Swipes = Custom"
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PrecisionTouchPad" -Name FourFingerSlideEnabled -Value 0xffff
    Write-Output "Bluetooth & devices > Touchpad > Advanced gestures > Configure four-finger gestures > Tap = Play/pause"
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PrecisionTouchPad" -Name FourFingerTapEnabled -Value 3
    Write-Output "Bluetooth & devices > Touchpad > Advanced gestures > Configure four-finger gestures > Swipe up = Volume up"
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PrecisionTouchPad" -Name FourFingerUp -Value 16
    Write-Output "Bluetooth & devices > Touchpad > Advanced gestures > Configure four-finger gestures > Swipe down = Volume down"
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PrecisionTouchPad" -Name FourFingerDown -Value 17
    Write-Output "Bluetooth & devices > Touchpad > Advanced gestures > Configure four-finger gestures > Swipe left = Next track"
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PrecisionTouchPad" -Name FourFingerLeft -Value 14
    Write-Output "Bluetooth & devices > Touchpad > Advanced gestures > Configure four-finger gestures > Swipe right = Previous track"
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PrecisionTouchPad" -Name FourFingerRight -Value 15
} -RequiresReboot
