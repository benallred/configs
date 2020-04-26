function StopOnError([int]$MinimumErrorCode, [scriptblock]$ScriptBlock) {
    Invoke-Command $ScriptBlock
    if ($LastExitCode -ge $MinimumErrorCode) {
        Read-Host
        Exit $LastExitCode
    }
}

StopOnError 1 {
    dotnet run --project $git\YouTubeToPlex\YouTubeToPlex\ -- --playlist-id PLAYgY8SPtEWGh243j2fmgeCxnFtpbWwZd --download-folder "E:\Media\Church\TV\Book of Mormon Videos"
    dotnet run --project $git\YouTubeToPlex\YouTubeToPlex\ -- --playlist-id PLGVpxD1HlmJ-OuDJlytqoxj5oEme6RSVz --download-folder "E:\Media\Ben\TV\Family TV\Studio C" --season 0
    dotnet run --project $git\YouTubeToPlex\YouTubeToPlex\ -- --playlist-id PLGVpxD1HlmJ-sdaH6yq_EC7248oXq1i6I --download-folder "E:\Media\Ben\TV\Family TV\Studio C" --season 10
}

& $PSScriptRoot\daily-backup.ps1
