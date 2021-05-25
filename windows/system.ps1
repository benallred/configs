Block "System > Power & sleep > Screen > On battery power, turn off after = 10 minutes" {
    powercfg /change monitor-timeout-dc 10
}
Block "System > Power & sleep > Screen > When plugged in, turn off after = 20 minutes" {
    powercfg /change monitor-timeout-ac 20
}
Block "System > Power & sleep > Sleep > On battery power, PC goes to sleep after = 20 minutes" {
    powercfg /change standby-timeout-dc 20
}
if ((Configured $forWork) -or (Configured $forKids)) {
    Block "System > Power & sleep > Sleep > When plugged in, PC goes to sleep after = 60 minutes" {
        powercfg /change standby-timeout-ac 60
    }
}
Block "System > Power & sleep > Additional power settings > Choose what closing the lid does > When I close the lid (Plugged in) = Do nothing" {
    # https://docs.microsoft.com/en-us/windows-hardware/customize/power-settings/power-button-and-lid-settings-lid-switch-close-action
    powercfg /SetACValueIndex SCHEME_BALANCED SUB_BUTTONS LIDACTION 0
    powercfg /SetDCValueIndex SCHEME_BALANCED SUB_BUTTONS LIDACTION 0
}
Block "System > Multitasking > Alt + Tab > Pressing Alt + Tab shows = Open windows only" {
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" MultiTaskingAltTabFilter 3
} -RequiresReboot
Block "System > Clipboard > Clipboard history = On" {
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Clipboard" EnableClipboardHistory 1
}
