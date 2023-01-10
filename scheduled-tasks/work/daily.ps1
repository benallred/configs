. $PSScriptRoot\..\functions.ps1

git config --global --unset user.email

& $PSScriptRoot\..\delete-desktop-shortcuts.ps1
& $PSScriptRoot\..\prune-transcripts.ps1
& $emConfigs\em-config.ps1
