. $PSScriptRoot\..\functions.ps1

StopOnError { dotnet run --project $git\YouTubeToPlex\YouTubeToPlex\ -- playlist --id PLAYgY8SPtEWGh243j2fmgeCxnFtpbWwZd --download-folder "E:\Media\Church\TV\Book of Mormon Videos" }
StopOnError { dotnet run --project $git\YouTubeToPlex\YouTubeToPlex\ -- playlist --id PLGVpxD1HlmJ-OuDJlytqoxj5oEme6RSVz --download-folder "E:\Media\Ben\TV\Family TV\Studio C" --season 0 }
StopOnError { dotnet run --project $git\YouTubeToPlex\YouTubeToPlex\ -- playlist --id PLGVpxD1HlmJ-sdaH6yq_EC7248oXq1i6I --download-folder "E:\Media\Ben\TV\Family TV\Studio C" --season 10 }
StopOnError { dotnet run --project $git\YouTubeToPlex\YouTubeToPlex\ -- playlist --id PLGVpxD1HlmJ8GxbiW7jdGzPlKJeO5sz3B --download-folder "E:\Media\Ben\TV\Family TV\Studio C" --season 11 }

& $PSScriptRoot\daily-backup.ps1
