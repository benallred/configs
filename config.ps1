[Diagnostics.CodeAnalysis.SuppressMessage("PSReviewUnusedParameter", "SkipBackup")]
param([switch]$DryRun, [switch]$SkipBackup, [string]$Run)

$totalDuration = [Diagnostics.Stopwatch]::StartNew()

. $PSScriptRoot\config-functions.ps1
mkdir C:\BenLocal\backup -ErrorAction Ignore

Block "Configure for" {
    $configureForOptions = {
        [Diagnostics.CodeAnalysis.SuppressMessage("PSUseDeclaredVarsMoreThanAssignments")]
        $forHome = "home"
        [Diagnostics.CodeAnalysis.SuppressMessage("PSUseDeclaredVarsMoreThanAssignments")]
        $forWork = "work"
        [Diagnostics.CodeAnalysis.SuppressMessage("PSUseDeclaredVarsMoreThanAssignments")]
        $forKids = "kids"
        [Diagnostics.CodeAnalysis.SuppressMessage("PSUseDeclaredVarsMoreThanAssignments")]
        $forHtpc = "htpc"
        [Diagnostics.CodeAnalysis.SuppressMessage("PSUseDeclaredVarsMoreThanAssignments")]
        $forTest = "test"
    }
    . $configureForOptions

    while (($configureFor = (Read-Host "Configure for ($forHome,$forWork,$forKids,$forHtpc,$forTest)")) -notin @($forHome, $forWork, $forKids, $forHtpc, $forTest)) { }

    if (!(Test-Path $profile)) {
        New-Item $profile -Force
    }

    Add-Content -Path $profile -Value "`n"
    Add-Content -Path $profile $configureForOptions
    Add-Content -Path $profile -Value "`$configureFor = `"$configureFor`""
    Add-Content -Path $profile {
        function Configured([Parameter(Mandatory)][ValidateSet("home", "work", "kids", "htpc", "test")][string[]]$for) {
            return $configureFor -in $for
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

if (Configured $forHome) {
    FirstRunBlock "Change drive letters" {
        # Consider using Set-Partition or Set-Volume
        start diskmgmt.msc
        Write-ManualStep "Change drive letters"
        Read-Host "Press Enter when done"
    }

    Block "Restore file backups" {
        wt -w 0 nt pwsh -NoExit -File $PSScriptRoot\restore-file-backups.ps1
    } {
        Test-Path C:\Ben
    }
}

& $PSScriptRoot\powershell\config.ps1
if (!$DryRun -and !$Run) {
    . $profile.AllUsersAllHosts
    . $profile.AllUsersCurrentHost
    . $profile.CurrentUserAllHosts
    . $profile.CurrentUserCurrentHost
    Update-WindowsTerminalSettings
}

Block "Git config" {
    git config --global --add include.path $PSScriptRoot\git\ben.gitconfig
} {
    (git config --get-all --global include.path) -match "ben\.gitconfig"
}

& $PSScriptRoot\windows\config.ps1
& $PSScriptRoot\install\install.ps1
if (Configured $forHome, $forWork, $forTest) {
    & $PSScriptRoot\work\config.ps1
}
& $PSScriptRoot\scheduled-tasks\config.ps1

# if (!(Configured $forKids)) {
#     FirstRunBlock "Defer config for Start Menu, Taskbar, and System Tray" {
#         New-FileRunOnce "Config for Start Menu, Taskbar, and System Tray" "$PSScriptRoot\windows\start-task-tray\start-task-tray.ps1"
#     } -RequiresReboot
# }

Block "Blocks of interest this run" {
    $global:blocksOfInterest | % { Write-Output "`t$_" }
} {
    $global:blocksOfInterest.Length -eq 0
}

Write-Output "Total duration: $($totalDuration.Elapsed)"
