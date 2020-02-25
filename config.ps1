param([switch]$DryRun, [switch]$Verbose)

function Write-IfVerbose([boolean]$DryRun, [boolean]$Verbose, [string]$Comment, [ConsoleColor]$ForegroundColor = "White") {
    if (!$DryRun -or $Verbose) {
        Write-Host $Comment -ForegroundColor $ForegroundColor
    }
}

function Block([string]$Comment, [scriptblock]$ScriptBlock, [scriptblock]$CompleteCheck, [switch]$RequiresReboot) {
    Write-IfVerbose $DryRun $Verbose (New-Object System.String -ArgumentList ('*', 100))
    if (!$DryRun) {
        Write-Output $Comment
    }
    if ($CompleteCheck -and (Invoke-Command $CompleteCheck)) {
        Write-IfVerbose $DryRun $Verbose "Already done"
        return
    }
    elseif ($DryRun) {
        Write-Output $Comment
    }
    if (!$DryRun) {
        if ($RequiresReboot) {
            Write-IfVerbose $DryRun $Verbose "This will take effect after a reboot" Yellow
        }
        Invoke-Command $ScriptBlock
    }
    else {
        Write-IfVerbose $DryRun $Verbose "This block would execute" Green
    }
}

Block "Configure for" {
    $forHome = "home"
    $forWork = "work"
    while (($configureFor = (Read-Host "Configure for ($forHome,$forWork)")) -notin @($forHome, $forWork)) { }
    if (!(Test-Path $profile)) {
        New-Item $profile -Force
    }
    Add-Content -Path $profile -Value "`n"
    Add-Content -Path $profile -Value "`$forHome = `"$forHome`""
    Add-Content -Path $profile -Value "`$forWork = `"$forWork`""
    Add-Content -Path $profile -Value "`$configureFor = `"$configureFor`""
    Add-Content -Path $profile -Value "`$configure = { `$args[0] -eq `$configureFor }"
} {
    (Test-Path $profile) -and (Select-String "\`$configureFor" $profile) # -Pattern is regex
}

& $PSScriptRoot\powershell\config.ps1
if (!$DryRun) {
    . $profile # make profile available to scripts below
}
Block "Git config" {
    git config --global --add include.path $PSScriptRoot\git\ben.gitconfig
} {
    (git config --get-all --global include.path) -match "ben.gitconfig"
}
& $PSScriptRoot\windows\config.ps1
& $PSScriptRoot\install\install.ps1
& $PSScriptRoot\scheduled-tasks\config.ps1
