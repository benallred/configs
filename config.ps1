param([switch]$DryRun)

. $PSScriptRoot\config-functions.ps1
mkdir C:\BenLocal\backup -ErrorAction Ignore

Block "Configure for" {
    $forHome = "home"
    $forWork = "work"
    $forTest = "test"
    while (($configureFor = (Read-Host "Configure for ($forHome,$forWork,$forTest)")) -notin @($forHome, $forWork, $forTest)) { }
    if (!(Test-Path $profile)) {
        New-Item $profile -Force
    }
    Add-Content -Path $profile -Value "`n"
    Add-Content -Path $profile -Value "`$forHome = `"$forHome`""
    Add-Content -Path $profile -Value "`$forWork = `"$forWork`""
    Add-Content -Path $profile -Value "`$forTest = `"$forTest`""
    Add-Content -Path $profile -Value "`$configureFor = `"$configureFor`""
    Add-Content -Path $profile -Value "`$configure = { `$args[0] -eq `$configureFor }"
} {
    (Test-Path $profile) -and (Select-String "\`$configureFor" $profile) # -Pattern is regex
}

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
& $PSScriptRoot\scheduled-tasks\config.ps1
