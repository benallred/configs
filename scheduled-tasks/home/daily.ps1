function StopOnError([int]$MinimumErrorCode, [scriptblock]$ScriptBlock) {
    Invoke-Command $ScriptBlock
    if ($LastExitCode -ge $MinimumErrorCode) {
        Read-Host
        Exit $LastExitCode
    }
}

StopOnError 1 {
    dotnet run --project $git\YouTubeToPlex\YouTubeToPlex\ -- --playlist-id PLAYgY8SPtEWGh243j2fmgeCxnFtpbWwZd --download-folder "E:\Media\Church\TV\Book of Mormon Videos"
}

& $PSScriptRoot\daily-backup.ps1
