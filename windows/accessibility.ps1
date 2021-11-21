Block "Accessibility > Narrator > Keyboard shortcut for Narrator = Off" {
    Set-RegistryValue "HKCU:\Software\Microsoft\Narrator\NoRoam" -Name WinEnterLaunchEnabled -Value 0
}
Block "Accessibility > Keyboard > Sticky keys > Keyboard shortcut for Sticky keys = Off" {
    Set-RegistryValue "HKCU:\Control Panel\Accessibility\StickyKeys" -Name Flags -Value 506
} -RequiresReboot
Block "Accessibility > Keyboard > Filter keys > Keyboard shortcut for Filter keys = Off" {
    Set-RegistryValue "HKCU:\Control Panel\Accessibility\Keyboard Response" -Name Flags -Value 122
} -RequiresReboot
Block "Control Panel > Ease of Access Center > Make the keyboard easier to use > Turn on Toggle Keys by holding down the NUM LOCK key for 5 seconds = Off" {
    Set-RegistryValue "HKCU:\Control Panel\Accessibility\ToggleKeys" -Name Flags -Value 58
} -RequiresReboot
Block "Accessibility > Keyboard > Underline access keys = On" {
    Set-RegistryValue "HKCU:\Control Panel\Accessibility\Keyboard Preference" -Name On -Value 1
} -RequiresReboot
Block "Accessibility > Keyboard > Use the Print screen button to open screen snipping = On" {
    Set-RegistryValue "HKCU:\Control Panel\Keyboard" -Name PrintScreenKeyForSnippingEnabled -Value 1
} -RequiresReboot
