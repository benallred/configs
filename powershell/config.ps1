Block "concfg" {
    scoop install concfg
    concfg import vs-code-dark-plus -n
    concfg clean
}

Block "posh-git" {
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Install-Module posh-git -Force
    Add-PoshGitToProfile -AllHosts
} {
    Get-Module posh-git
}

Block "PowerShell Transcripts" {
    mkdir "C:\BenLocal\PowerShell Transcripts" -ErrorAction Ignore
}

Block "profile.ps1" {
    Add-Content -Path $profile -Value "`n. $PSScriptRoot\profile.ps1"
} {
    (Test-Path $profile) -and (Select-String "$($PSScriptRoot -replace "\\", "\\")\\profile.ps1" $profile) # <original> is regex, <substitute> is PS string
}

Block "Update PS help" {
    if (!(& $configure $forTest)) {
        Update-Help
    }
}
