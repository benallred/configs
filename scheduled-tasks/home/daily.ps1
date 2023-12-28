. $PSScriptRoot\..\functions.ps1

git config --global --unset user.email

& $PSScriptRoot\..\delete-desktop-shortcuts.ps1
& $PSScriptRoot\..\prune-transcripts.ps1
& $PSScriptRoot\daily-backup.ps1

StopOnError 8 {
    $saveFolder = "C:\BenEx\Humor\Dilbert"
    dotnet run --project $git\DilbertImageDownloader\ -- --save-folder=$saveFolder
    robocopy $saveFolder C:\Ben\Desktop\Miguk\Dilbert /S /MAXAGE:1
}
# StopOnError { dotnet run --project $git\YouTubeToPlex\YouTubeToPlex\ -- playlist --id PLAYgY8SPtEWGh243j2fmgeCxnFtpbWwZd --download-folder "E:\Media\Church\TV\Book of Mormon Videos" }
# StopOnError { dotnet run --project $git\YouTubeToPlex\YouTubeToPlex\ -- playlist --id PLGVpxD1HlmJ-OuDJlytqoxj5oEme6RSVz --download-folder "E:\Media\Ben\TV\Family TV\Studio C" --season 0 }
# StopOnError { dotnet run --project $git\YouTubeToPlex\YouTubeToPlex\ -- playlist --id PLcnZqvqjU4U1dSZs-DUoh4hm9Dil_rXQC --download-folder "E:\Media\Ben\TV\Family TV\Studio C" --season 13 }
# StopOnError { dotnet run --project $git\YouTubeToPlex\YouTubeToPlex\ -- playlist --id PLGVpxD1HlmJ94Emxl7cxlAXfq3CfabhW4 --download-folder "E:\Media\Ben\TV\Family TV\Studio C" --season 14 }
# StopOnError { dotnet run --project $git\YouTubeToPlex\YouTubeToPlex\ -- playlist --id PLGVpxD1HlmJ98VLS8yGvHxXKeiIeYNzUo --download-folder "E:\Media\Ben\TV\Family TV\Studio C" --season 15 }
# StopOnError { dotnet run --project $git\YouTubeToPlex\YouTubeToPlex\ -- playlist --id PLGVpxD1HlmJ_MACuBYpU2K2qqHCoQJ7c4 --download-folder "E:\Media\Ben\TV\Family TV\Studio C" --season 16 }
