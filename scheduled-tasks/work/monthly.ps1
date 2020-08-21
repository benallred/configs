. $PSScriptRoot\..\functions.ps1

$runTimeId = "monthly"

if (AlreadyRunThisMonth $runTimeId) {
    return
}

Update-Help -ErrorAction Ignore

RecordRunTime $runTimeId
