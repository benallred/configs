. $PSScriptRoot\..\functions.ps1

$runTimeId = "monthly"

if (AlreadyRunThisMonth $runTimeId) {
    return
}

mkdir $tmp -ErrorAction Ignore | Out-Null

function Backup([string]$From, [string]$To, [switch]$IsMediaBackup) {
    $logFile = "$To.log"
    Write-Output "Backing up $From to $To"
    Write-Output "Writing log file to $logFile"
    # /J           = copy using unbuffered I/O (recommended for large files)
    $mediaBackupSwitches = $IsMediaBackup ? "/J" : ""
    # /Z           = copy files in restartable mode
    # /DCOPY:T     = COPY Directory Timestamps
    # /MIR         = MIRror a directory tree (equivalent to /E plus /PURGE)
    # /X           = report all eXtra files, not just those selected
    # /NDL         = No Directory List - don't log directory names
    # /NP          = No Progress - don't display percentage copied
    # /UNILOG:file = output status to LOG file as UNICODE (overwrite existing log)
    # /TEE         = output to console window, as well as the log file
    StopOnError 4 { robocopy $From $To /Z /DCOPY:T /MIR /X /NDL /NP /UNILOG:"$logFile" /TEE $mediaBackupSwitches }
    start $logFile
}

function BackupByMonth([string]$From, [string]$ToBase) {
    # 12 months of backups
    # $MonthAbbr = Get-Date -Format "MMM"
    # $MonthNumber = Get-Date -Format "MM"
    # 3 months of backups
    $monthAbbr = switch ((Get-Date).Month % 3) {
        1 { "Jan,Apr,Jul,Oct" }
        2 { "Feb,May,Aug,Nov" }
        0 { "Mar,Jun,Sep,Dec" }
    }
    $monthNumber = switch ((Get-Date).Month % 3) {
        0 { 3 }
        Default { $_ }
    }
    $to = "$ToBase\$monthNumber $monthAbbr"
    Backup $From $to
}

function BackupOneDrive() {
    $from = "$env:UserProfile\OneDrive"
    $to = "E:\Backup - Monthly\OneDrive"
    $logFile = "$to.log"
    Write-Output "Backing up $from to $to"
    Write-Output "Writing log file to $logFile"
    StopOnError 4 { robocopy $from $to /XD $env:UserProfile\OneDrive\Ben $env:UserProfile\OneDrive\BenEx $env:UserProfile\OneDrive\Music /XF (Get-ChildItem $env:UserProfile\OneDrive\ -Hidden) /Z /DCOPY:T /MIR /X /NDL /NP /UNILOG:"$logFile" /TEE }
    start $logFile
}

BackupByMonth "C:\Ben" "E:\Backup - Monthly\Ben"
Backup "C:\BenEx" "E:\Backup - Monthly\BenEx"
Backup "C:\BenEx2" "E:\Backup - Monthly\BenEx2"
BackupByMonth "$env:UserProfile\OneDrive\Ben" "E:\Backup - Monthly\OneDrive_Ben"
BackupByMonth "$env:UserProfile\OneDrive\Music" "E:\Backup - Monthly\OneDrive_Music"
BackupByMonth "$env:UserProfile\OneDrive\BenEx" "E:\Backup - Monthly\OneDrive_BenEx"
BackupOneDrive

Backup E:\Media\Ben J:\MediaBackup\Media\Ben -IsMediaBackup
Backup "E:\Media (Korean)" "J:\MediaBackup\Media (Korean)" -IsMediaBackup
Backup E:\Media\Tools J:\MediaBackup\Media\Tools

Backup "$env:LOCALAPPDATA\Plex Media Server" "E:\Backup - Monthly\AppData\Local\Plex Media Server"
StopOnError { reg export "HKCU\SOFTWARE\Plex, Inc.\Plex Media Server" "E:\Backup - Monthly\reg-Plex Media Server.reg" /y }
StopOnError { reg export "HKCU\SOFTWARE\PlexPlaylistLiberator" "E:\Backup - Monthly\reg-PlexPlaylistLiberator.reg" /y }

Update-Help -ErrorAction Ignore

RecordRunTime $runTimeId
