Block "Scheduled Tasks: Home: Daily" {
    $action = New-ScheduledTaskAction -Execute "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument "& '$PSScriptRoot\daily.ps1'"
    $trigger = New-ScheduledTaskTrigger -Daily -At 07:00
    $settingsSet = New-ScheduledTaskSettingsSet -StartWhenAvailable
    $task = New-ScheduledTask -Action $action -Trigger $trigger -Settings $settingsSet
    Register-ScheduledTask -TaskName "Daily (Home)" -TaskPath "Ben" -InputObject $task
} {
    Get-ScheduledTask -TaskName "Daily (Home)" -TaskPath "\Ben\" -ErrorAction Ignore
}
