param([switch]$DryRun)

. $PSScriptRoot\config-functions.ps1
mkdir C:\BenLocal\backup -ErrorAction Ignore

Block "Backup Registry" {
    if (!(& $configure $forTest)) {
        & $PSScriptRoot\backup-registry.ps1
    }
}

& $PSScriptRoot\powershell\config.ps1
if (!$DryRun) {
    . $profile # make profile available to scripts below
}

Block "Git config" {
    git config --global --add include.path $PSScriptRoot\git\ben.gitconfig
} {
    (git config --get-all --global include.path) -match "ben\.gitconfig"
}

& $PSScriptRoot\windows\config.ps1
& $PSScriptRoot\install\install.ps1
