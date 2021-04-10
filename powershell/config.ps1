Block "Install posh-git" {
    Install-Module posh-git -Force
    Add-PoshGitToProfile -AllHosts
} {
    Get-Module -ListAvailable posh-git
}

if (!(Configured $forKids)) {
    Block "Install BurntToast" {
        Install-Module BurntToast -Force
    } {
        Get-Module -ListAvailable BurntToast
    }
}

Block "PowerShell Transcripts" {
    mkdir "C:\BenLocal\PowerShell Transcripts" -ErrorAction Ignore
}

Block "Configure profile.ps1" {
    Add-Content -Path $profile -Value "`n. $PSScriptRoot\profile.ps1"
} {
    (Test-Path $profile) -and (Select-String "$($PSScriptRoot -replace "\\", "\\")\\profile.ps1" $profile) # <original> is regex, <substitute> is PS string
}

InstallFromMicrosoftStoreBlock "Windows Terminal" 9n0dx20hk701 Microsoft.WindowsTerminal

if (!(Configured $forTest)) {
    FirstRunBlock "Update PS help" {
        Update-Help -ErrorAction Ignore
    }
}
