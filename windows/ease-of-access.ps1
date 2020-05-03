Block "Ease of Access > Narrator > Allow the shortcut key to start Narrator = Off" {
    Set-ItemProperty "HKCU:\Software\Microsoft\Narrator\NoRoam" -Name WinEnterLaunchEnabled -Value 0
}
Block "Ease of Access > Keyboard > Allow the shortcut key to start Sticky Keys = Off" {
    Set-ItemProperty "HKCU:\Control Panel\Accessibility\StickyKeys" -Name Flags -Value 506
} -RequiresReboot
Block "Ease of Access > Keyboard > Allow the shortcut key to start Toggle Keys = Off" {
    Set-ItemProperty "HKCU:\Control Panel\Accessibility\ToggleKeys" -Name Flags -Value 58
} -RequiresReboot
Block "Ease of Access > Keyboard > Allow the shortcut key to start Filter Keys = Off" {
    Set-ItemProperty "HKCU:\Control Panel\Accessibility\Keyboard Response" -Name Flags -Value 122
} -RequiresReboot
Block "Ease of Access > Keyboard > Underline access keys when available = On" {
    Set-ItemProperty "HKCU:\Control Panel\Accessibility\Keyboard Preference" -Name On -Value 1
} -RequiresReboot
Block "Ease of Access > Keyboard > Use the PrtScn button to open screen snipping = On" {
    Set-ItemProperty "HKCU:\Control Panel\Keyboard" -Name PrintScreenKeyForSnippingEnabled -Value 1
} -RequiresReboot
