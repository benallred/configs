function BackupByDay([string]$From, [string]$ToBase) {
    $weekday = Get-Date -Format "ddd"
    $weekdayNumber = (Get-Date).DayOfWeek.value__
    $to = "$ToBase\$weekdayNumber $weekday"
    $logFile = "$to.log"
    Write-Output "Backing up $From to $to"
    Write-Output "Writing log file to $logFile"
    # /Z           = copy files in restartable mode
    # /DCOPY:T     = COPY Directory Timestamps
    # /MIR         = MIRror a directory tree (equivalent to /E plus /PURGE)
    # /X           = report all eXtra files, not just those selected
    # /NDL         = No Directory List - don't log directory names
    # /NP          = No Progress - don't display percentage copied
    # /UNILOG:file = output status to LOG file as UNICODE (overwrite existing log)
    # /TEE         = output to console window, as well as the log file
    StopOnError 4 { robocopy $From $to /Z /DCOPY:T /MIR /X /NDL /NP /UNILOG:"$logFile" /TEE }
}

BackupByDay "C:\Ben" "J:\Backup - Daily\Ben"
BackupByDay "$env:UserProfile\OneDrive\Ben" "J:\Backup - Daily\OneDrive_Ben"
BackupByDay "$env:UserProfile\OneDrive\Music" "J:\Backup - Daily\OneDrive_Music"
