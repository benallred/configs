FirstRunBlock "Devices > Printers & scanners > Add a printer or scanner > The printer that I want isn't listed" {
    if (!(Configured $forHome)) {
        Write-ManualStep "Select a shared printer by name = \\{Server}\{Printer}"
        rundll32 printui.dll PrintUIEntry /im
        WaitWhileProcess rundll32
    }
}
Block "Devices > Touchpad > Three-finger gestures > Taps = Middle mouse button" {
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PrecisionTouchPad" -Name ThreeFingerTapEnabled -Value 4
} -RequiresReboot
