. $PSScriptRoot\..\functions.ps1

git config --global --unset user.email

& $PSScriptRoot\..\delete-desktop-shortcuts.ps1
& $PSScriptRoot\..\configure-phone-link-notifications.ps1
& $PSScriptRoot\..\prune-transcripts.ps1
StopOnError { & $workConfigs\work-config.ps1 }

StopOnError {
    Stop-Process -Name PowerToys
    WaitWhileProcess PowerToys
    Copy-Item (Get-Random (Get-ChildItem "$env:OneDrive\Ben\Settings\Backgrounds - Work\Despair, Inc")) C:\BenLocal\VCM_Random.jpg
    . "$env:ProgramFiles\PowerToys\PowerToys.exe"
}
