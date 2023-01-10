function ScheduledTaskBlock([Parameter(Mandatory)][string]$Comment, [Parameter(Mandatory)][string]$ScriptFilePath, [Parameter(Mandatory)][string]$TaskName, [DateTime]$Time) {
    Block $Comment {
        $at = if ($Time) { $Time } else { "07:00" }
        $action = New-ScheduledTaskAction -Execute (Get-Command wt).Source -Argument "-w scheduled-tasks pwsh -Command `"Start-AsAdmin '$ScriptFilePath'`""
        $trigger = New-ScheduledTaskTrigger -Daily -At $at
        $settingsSet = New-ScheduledTaskSettingsSet -StartWhenAvailable
        $task = New-ScheduledTask -Action $action -Trigger $trigger -Settings $settingsSet
        Register-ScheduledTask -TaskName $TaskName -TaskPath "Ben" -InputObject $task
    } {
        Get-ScheduledTask -TaskName $TaskName -TaskPath "\Ben\" -ErrorAction Ignore
    }
}

if (Configured $forHome) {
    & $PSScriptRoot\home\config.ps1
}
elseif (Configured $forWork) {
    & $PSScriptRoot\work\config.ps1
}
