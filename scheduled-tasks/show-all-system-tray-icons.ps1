. $PSScriptRoot\..\config-functions.ps1

Write-Output ("*" * $Host.UI.RawUI.WindowSize.Width)
Write-Output "Personalization > Taskbar > Other system tray icons = All on"

Get-ChildItem "HKCU:\Control Panel\NotifyIconSettings" |
    % {
        $notifyIconRegPath = $_.Name -replace "HKEY_CURRENT_USER", "HKCU:"
        $notifyIconId = Split-Path $_ -Leaf
        $process = Split-Path $_.GetValue("ExecutablePath") -Leaf
        Write-Output "`t$process ($notifyIconId)"
        Set-RegistryValue $notifyIconRegPath -Name IsPromoted -Value 1
    }
