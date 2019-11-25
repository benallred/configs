# New-ScheduledTaskTrigger doesn't currently have a -Monthly option so this script is set to run daily
# Return if already run this month
$now = Get-Date
$beginningOfMonth = Get-Date -Year $now.Year -Month $now.Month -Day 1 -Hour 0 -Minute 0 -Second 0 -Millisecond 0
$lastRunTime = ${C:\BenLocal\.ps.monthly-lastruntime.txt}
if ($lastRunTime -ge $beginningOfMonth) {
    return
}

function StopOnError([int]$MinimumErrorCode, [scriptblock]$ScriptBlock) {
    Invoke-Command $ScriptBlock
    if ($LastExitCode -ge $MinimumErrorCode) {
        Read-Host
        Exit $LastExitCode
    }
}

function Backup([string]$from, [string]$to) {
    $logFile = "$to.log"
    Write-Output "Backing up $from to $to"
    Write-Output "Writing log file to $logFile"
    # /Z           = copy files in restartable mode
    # /DCOPY:T     = COPY Directory Timestamps
    # /MIR         = MIRror a directory tree (equivalent to /E plus /PURGE)
    # /X           = report all eXtra files, not just those selected
    # /NDL         = No Directory List - don't log directory names
    # /NP          = No Progress - don't display percentage copied
    # /UNILOG:file = output status to LOG file as UNICODE (overwrite existing log)
    # /TEE         = output to console window, as well as the log file
    StopOnError 4 { robocopy $from $to /Z /DCOPY:T /MIR /X /NDL /NP /UNILOG:"$logFile" /TEE }
    start $logFile
}

function BackupByMonth([string]$from, [string]$toBase) {
    # 12 months of backups
    # $MonthAbbr = Get-Date -Format "MMM"
    # $MonthNumber = Get-Date -Format "MM"
    # 3 months of backups
    $MonthAbbr = switch ((Get-Date).Month % 3) {
        1 { "Jan,Apr,Jul,Oct" }
        2 { "Feb,May,Aug,Nov" }
        0 { "Mar,Jun,Sep,Dec" }
    }
    $MonthNumber = switch ((Get-Date).Month % 3) {
        0 { 3 }
        Default { $_ }
    }
    $to = "$toBase\$MonthNumber $MonthAbbr"
    Backup $from $to
}

BackupByMonth "C:\Ben" "J:\Backup - Monthly\Ben"
Backup "C:\BenEx" "J:\Backup - Monthly\BenEx"
Backup "C:\BenEx2" "J:\Backup - Monthly\BenEx2"
BackupByMonth "$env:UserProfile\OneDrive\Ben" "J:\Backup - Monthly\OneDrive_Ben"
BackupByMonth "$env:UserProfile\OneDrive\Music" "J:\Backup - Monthly\OneDrive_Music"
BackupByMonth "$env:UserProfile\OneDrive\BenEx" "J:\Backup - Monthly\OneDrive_BenEx"
Backup "$env:UserProfile\OneDrive\BenEx2" "J:\Backup - Monthly\OneDrive_BenEx2"

${C:\BenLocal\.ps.monthly-lastruntime.txt} = Get-Date
