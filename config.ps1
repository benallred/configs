param([switch]$DryRun, [switch]$SkipBackup, [string]$Run)

. $PSScriptRoot\config-functions.ps1
mkdir C:\BenLocal\backup -ErrorAction Ignore

Block "Configure for" {
    $configureForOptions = {
        $forHome = "home"
        $forWork = "work"
        $forTest = "test"
    }
    . $configureForOptions

    while (($configureFor = (Read-Host "Configure for ($forHome,$forWork,$forTest)")) -notin @($forHome, $forWork, $forTest)) { }

    if (!(Test-Path $profile)) {
        New-Item $profile -Force
    }

    Add-Content -Path $profile -Value "`n"
    Add-Content -Path $profile $configureForOptions
    Add-Content -Path $profile -Value "`$configureFor = `"$configureFor`""
    Add-Content -Path $profile {
        function Configured([Parameter(Mandatory = $true)][ValidateSet("home", "work", "test")][string]$for) {
            if (!$configureFor) {
                throw '$configureFor not set'
            }
            $for -eq $configureFor
        }
    }
} {
    (Test-Path $profile) -and (Select-String "\`$configureFor" $profile) # -Pattern is regex
}
if (!$DryRun -and !$Run) { . $profile } # make profile available to scripts below

Block "Backup Registry" {
    if (!(Configured $forTest)) {
        & $PSScriptRoot\backup-registry.ps1
    }
} {
    $SkipBackup
}

& $PSScriptRoot\powershell\config.ps1
if (!$DryRun -and !$Run) { . $profile } # make profile available to scripts below

Block "Git config" {
    git config --global --add include.path $PSScriptRoot\git\ben.gitconfig
} {
    (git config --get-all --global include.path) -match "ben\.gitconfig"
}

& $PSScriptRoot\windows\config.ps1
& $PSScriptRoot\install\install.ps1
& $PSScriptRoot\work\config.ps1
& $PSScriptRoot\scheduled-tasks\config.ps1

FirstRunBlock "Defer config for Start Menu, Taskbar, and System Tray" {
    Create-FileRunOnce "Config for Start Menu, Taskbar, and System Tray" "$PSScriptRoot\windows\start-task-tray\start-task-tray.ps1"
} -RequiresReboot
