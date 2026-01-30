Block "System > Power & battery > Power mode = Recommended" {
    powercfg /SetActive SCHEME_BALANCED
}
Block "System > Power & battery > Screen, sleep, & hibernate timeouts > On battery > Turn off my screen after = 3 minutes" {
    powercfg /change monitor-timeout-dc 3
}
Block "System > Power & battery > Screen, sleep, & hibernate timeouts > Plugged in > Turn off my screen after = 5 minutes" {
    powercfg /change monitor-timeout-ac 5
}
Block "System > Power & battery > Screen, sleep, & hibernate timeouts > On battery > Make my device sleep after = 5 minutes" {
    powercfg /change standby-timeout-dc 5
}
Block "System > Power & battery > Screen, sleep, & hibernate timeouts > Plugged in > Make my device sleep after =" {
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
Block "System > Power & battery > Lid & power button controls > On battery > Closing the lid will make my PC = Sleep" {
    # https://docs.microsoft.com/en-us/windows-hardware/customize/power-settings/power-button-and-lid-settings-lid-switch-close-action
    powercfg /SetDCValueIndex SCHEME_BALANCED SUB_BUTTONS LIDACTION 1
} -RequiresReboot
Block "System > Power & battery > Lid & power button controls > Plugged in > Closing the lid will make my PC = Do Nothing" {
    # https://docs.microsoft.com/en-us/windows-hardware/customize/power-settings/power-button-and-lid-settings-lid-switch-close-action
    powercfg /SetACValueIndex SCHEME_BALANCED SUB_BUTTONS LIDACTION 0
} -RequiresReboot
Block "System > Multitasking > Alt + Tab > Pressing Alt + Tab shows = Open windows only" {
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" MultiTaskingAltTabFilter 3
} -RequiresReboot
Block "System > Clipboard > Clipboard history = On" {
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Clipboard" EnableClipboardHistory 1
}
