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

if (& $configure $forHome) {
    & $PSScriptRoot\home\config.ps1
}
elseif (& $configure $forWork) {
    & $PSScriptRoot\work\config.ps1
}
