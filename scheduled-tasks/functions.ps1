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

function StopOnError(
    [Parameter(ParameterSetName = "MinimumErrorCode", Mandatory, Position = 0)]
    [int]$MinimumErrorCode,
    [Parameter(ParameterSetName = "MinimumErrorCode", Mandatory, Position = 1)]
    [Parameter(ParameterSetName = "NonZero", Mandatory, Position = 0)]
    [scriptblock]$ScriptBlock) {
    $global:LastExitCode = 0
    $ErrorActionPreference = 'Stop'
    Invoke-Command $ScriptBlock
    if (($PSCmdlet.ParameterSetName -eq "NonZero" -and $LastExitCode) -or ($PSCmdlet.ParameterSetName -eq "MinimumErrorCode" -and $LastExitCode -ge $MinimumErrorCode)) {
        throw "Received exit code $LastExitCode"
    }
}
