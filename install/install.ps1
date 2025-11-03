InstallFromWingetBlock Git.Git

Block "Configure scoop extras bucket" {
    scoop bucket add extras
} {
    scoop bucket list | Select-String extras
}

Block "Configure scoop nonportable bucket" {
    scoop bucket add nonportable
} {
    scoop bucket list | Select-String nonportable
}

& $PSScriptRoot\productivity.ps1
& $PSScriptRoot\dev.ps1
& $PSScriptRoot\devices.ps1
& $PSScriptRoot\system-utils.ps1
& $PSScriptRoot\media.ps1
& $PSScriptRoot\repos.ps1
& $PSScriptRoot\other.ps1
& $PSScriptRoot\games.ps1
