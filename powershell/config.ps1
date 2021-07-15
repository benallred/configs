Block "Install posh-git" {
    Install-Module posh-git -Force
    Add-PoshGitToProfile -AllHosts
} {
    Get-Module -ListAvailable posh-git
}

Block "Install oh-my-posh" {
    Install-Module oh-my-posh -Scope CurrentUser -AllowPrerelease -Force
} {
    Get-Module -ListAvailable oh-my-posh
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

Block "Configure scoop nerd-fonts bucket" {
    scoop bucket add nerd-fonts
} {
    scoop bucket list | Select-String nerd-fonts
}

InstallFromScoopBlock "Cascadia Code" CascadiaCode-NF

if (!(Configured $forTest)) {
    FirstRunBlock "Update PS help" {
        Update-Help -ErrorAction Ignore
    }
}
