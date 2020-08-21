# New-ScheduledTaskTrigger doesn't currently have a -Monthly option so monthly scripts are set to run daily and return if already run this month
function AlreadyRunThisMonth([string]$Id) {
    $now = Get-Date
    $beginningOfMonth = Get-Date -Year $now.Year -Month $now.Month -Day 1 -Hour 0 -Minute 0 -Second 0 -Millisecond 0
    $lastRunTimeContents = Get-Content C:\BenLocal\.ps.lastRunTime.$Id.txt -ErrorAction Ignore
    $lastRunTime = Get-Date $(if ($lastRunTimeContents) { $lastRunTimeContents } else { 0 })
    return $lastRunTime -ge $beginningOfMonth
}

function RecordRunTime([string]$Id) {
    Set-Content C:\BenLocal\.ps.lastRunTime.$Id.txt (Get-Date)
}

function StopOnError([int]$MinimumErrorCode, [scriptblock]$ScriptBlock) {
    Invoke-Command $ScriptBlock
    if ($LastExitCode -ge $MinimumErrorCode) {
        Write-Host "Received exit code $LastExitCode" -ForegroundColor Red
        Read-Host
        Exit $LastExitCode
    }
}
