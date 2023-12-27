Block "System > Power & battery > Power mode = Balanced" {
    powercfg /SetActive SCHEME_BALANCED
}
Block "System > Power & battery > Screen and sleep > On battery power, turn off my screen after = 10 minutes" {
    powercfg /change monitor-timeout-dc 10
}
Block "System > Power & battery > Screen and sleep > When plugged in, turn off my screen after = 20 minutes" {
    powercfg /change monitor-timeout-ac 20
}
Block "System > Power & battery > Screen and sleep > On battery power, put my device to sleep after = 20 minutes" {
    powercfg /change standby-timeout-dc 20
}
Block "System > Power & battery > Screen and sleep > When plugged in, put my device to sleep after =" {
    if (Configured $forHome, $forTest) {
        Write-Output "Never"
        powercfg /change standby-timeout-ac 0
    }
    elseif (Configured $forWork) {
        Write-Output "1.5 hours"
        powercfg /change standby-timeout-ac 90
    }
    else {
        Write-Output "30 minutes"
        powercfg /change standby-timeout-ac 30
    }
}
Block "Control Panel > Power Options > Choose what closing the lid does > When I close the lid (On battery) = Sleep" {
    # https://docs.microsoft.com/en-us/windows-hardware/customize/power-settings/power-button-and-lid-settings-lid-switch-close-action
    powercfg /SetDCValueIndex SCHEME_BALANCED SUB_BUTTONS LIDACTION 1
} -RequiresReboot
Block "Control Panel > Power Options > Choose what closing the lid does > When I close the lid (Plugged in) = Do nothing" {
    # https://docs.microsoft.com/en-us/windows-hardware/customize/power-settings/power-button-and-lid-settings-lid-switch-close-action
    powercfg /SetACValueIndex SCHEME_BALANCED SUB_BUTTONS LIDACTION 0
} -RequiresReboot
Block "System > Multitasking > Alt + Tab > Pressing Alt + Tab shows = Open windows only" {
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" MultiTaskingAltTabFilter 3
} -RequiresReboot
Block "System > Clipboard > Clipboard history = On" {
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Clipboard" EnableClipboardHistory 1
}
Block "System > Clipboard > Sync across your devices = On" {
    WaitWhileProcess SystemSettings
    Write-ManualStep "System > Clipboard > Sync across your devices = On"
    start ms-settings:clipboard
    # Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Clipboard" EnableCloudClipboard 1
}
Block "System > Clipboard > Sync across your devices = Manually sync text that I copy" {
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Clipboard" CloudClipboardAutomaticUpload 0
}
