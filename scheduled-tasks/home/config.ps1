function ScheduledTaskBlock([string]$Comment, [string]$ScriptFilePath, [string]$TaskName) {
    Block $Comment {
        $action = New-ScheduledTaskAction -Execute "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument "& '$ScriptFilePath'"
        $trigger = New-ScheduledTaskTrigger -Daily -At 07:00
        $settingsSet = New-ScheduledTaskSettingsSet -StartWhenAvailable
        $task = New-ScheduledTask -Action $action -Trigger $trigger -Settings $settingsSet
        Register-ScheduledTask -TaskName $TaskName -TaskPath "Ben" -InputObject $task
    } {
        Get-ScheduledTask -TaskName $TaskName -TaskPath "\Ben\" -ErrorAction Ignore
    }
}

ScheduledTaskBlock "Scheduled Tasks: Home: Daily" "$PSScriptRoot\daily.ps1" "Daily (Home)"
ScheduledTaskBlock "Scheduled Tasks: Home: Monthly" "$PSScriptRoot\monthly.ps1" "Monthly (Home)"
