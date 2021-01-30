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
    Get-Module -ListAvailable posh-git
}

if (!(Configured $forKids)) {
    Block "BurntToast" {
        Install-Module BurntToast -Force
    } {
        Get-Module -ListAvailable BurntToast
    }
}

Block "PowerShell Transcripts" {
    mkdir "C:\BenLocal\PowerShell Transcripts" -ErrorAction Ignore
}

Block "profile.ps1" {
    Add-Content -Path $profile -Value "`n. $PSScriptRoot\profile.ps1"
} {
    (Test-Path $profile) -and (Select-String "$($PSScriptRoot -replace "\\", "\\")\\profile.ps1" $profile) # <original> is regex, <substitute> is PS string
}

Block "Install Windows Terminal" {
    Write-ManualStep "Install Windows Terminal"
    start ms-windows-store://pdp/?ProductId=9n0dx20hk701
} {
    Get-AppxPackage -Name Microsoft.WindowsTerminal
}

Block "Configure Windows Terminal" {
    function GetSettingsDir() {
        "$env:LocalAppData\Packages\$((Get-AppxPackage -Name Microsoft.WindowsTerminal).PackageFamilyName)\LocalState"
    }
    WaitWhile { !(Test-Path (GetSettingsDir)) } "Waiting for Windows Terminal to be installed"
    Copy-Item $PSScriptRoot\settings.json "$(GetSettingsDir)\settings.json"
}

if (!(Configured $forTest)) {
    FirstRunBlock "Update PS help" {
        Update-Help -ErrorAction Ignore
    }
}
