Block "PowerShell Transcripts" {
    mkdir "C:\BenLocal\PowerShell Transcripts" -ErrorAction Ignore
}

Block "profile.ps1" {
    if (!(Test-Path $profile)) {
        New-Item $profile -Force
    }
    Add-Content -Path $profile -Value "`n. $PSScriptRoot\profile.ps1"
} {
    (Test-Path $profile) -and (Select-String "$($PSScriptRoot -replace "\\", "\\")\\profile.ps1" $profile) # <original> is regex, <substitute> is PS string
}

Block "Update PS help" {
    if (!(& $configure $forTest)) {
        Update-Help
    }
}
