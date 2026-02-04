. $PSScriptRoot\..\config-functions.ps1

function Reset-Notification([Parameter(Mandatory)][string]$AppId) {
    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\$AppId"
    Remove-ItemProperty -Path $path -Name Enabled -ErrorAction SilentlyContinue
    ConfigureNotifications $AppId ShowInActionCenter $false
}

Write-Output ("*" * $Host.UI.RawUI.WindowSize.Width)
Write-Output "Configuring Phone Link notifications"

Get-ChildItem "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" |
    ? { $_.PSChildName -like "Microsoft.YourPhone_8wekyb3d8bbwe!YourPhoneNotifications_*" } |
    % {
        Write-Output "`t$((Split-Path $_ -Leaf) -replace 'Microsoft.YourPhone_8wekyb3d8bbwe!YourPhoneNotifications_', '')"
        ConfigureNotifications $_.PSChildName Enabled $false
    }

Reset-Notification Microsoft.YourPhone_8wekyb3d8bbwe!YourPhoneNotifications_com.digibites.calendar
Reset-Notification Microsoft.YourPhone_8wekyb3d8bbwe!YourPhoneNotifications_com.microsoft.appmanager
Reset-Notification Microsoft.YourPhone_8wekyb3d8bbwe!YourPhoneNotifications_com.oceanwing.battery.cam
Reset-Notification Microsoft.YourPhone_8wekyb3d8bbwe!YourPhoneNotifications_com.samsung.android.oneconnect
