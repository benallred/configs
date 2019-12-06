Block "Ease of Access > Narrator > Allow the shortcut key to start Narrator = Off" {
    Set-ItemProperty "HKCU:\Software\Microsoft\Narrator\NoRoam" -Name WinEnterLaunchEnabled -Value 0
}
Block "Ease of Access > Keyboard > Allow the shortcut key to start Sticky Keys = Off" {
    Write-Host "This will take effect after a reboot" -ForegroundColor Yellow
    Set-ItemProperty "HKCU:\Control Panel\Accessibility\StickyKeys" -Name Flags -Value 506
}
Block "Ease of Access > Keyboard > Allow the shortcut key to start Toggle Keys = Off" {
    Write-Host "This will take effect after a reboot" -ForegroundColor Yellow
    Set-ItemProperty "HKCU:\Control Panel\Accessibility\ToggleKeys" -Name Flags -Value 58
}
Block "Ease of Access > Keyboard > Allow the shortcut key to start Filter Keys = Off" {
    Write-Host "This will take effect after a reboot" -ForegroundColor Yellow
    Set-ItemProperty "HKCU:\Control Panel\Accessibility\Keyboard Response" -Name Flags -Value 122
}
Block "Ease of Access > Keyboard > Underline access keys when available = On" {
    Write-Host "This will take effect after a reboot" -ForegroundColor Yellow
    Set-ItemProperty "HKCU:\Control Panel\Accessibility\Keyboard Preference" -Name On -Value 1
}
