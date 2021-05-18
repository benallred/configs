. $PSScriptRoot\..\functions.ps1

$runTimeId = "monthly"

if (AlreadyRunThisMonth $runTimeId) {
    return
}

mkdir $tmp -ErrorAction Ignore | Out-Null

Update-Help -ErrorAction Ignore

RecordRunTime $runTimeId
