param([switch]$DryRun)

function Block([string]$Comment, [scriptblock]$ScriptBlock, [scriptblock]$CompleteCheck, [switch]$RequiresReboot) {
    Write-Output (New-Object System.String -ArgumentList ('*', 100))
    Write-Output $Comment
    if ($CompleteCheck -and (Invoke-Command $CompleteCheck)) {
        Write-Output "Already done"
        return
    }
    if (!$DryRun) {
        if ($RequiresReboot) {
            Write-Host "This will take effect after a reboot" -ForegroundColor Yellow
        }
        Invoke-Command $ScriptBlock
    }
    else {
        Write-Host "This block would execute" -ForegroundColor Green
    }
}

function FirstRunBlock([string]$Comment, [scriptblock]$ScriptBlock, [switch]$RequiresReboot) {
    Block $Comment {
        Invoke-Command $ScriptBlock
        Add-Content C:\BenLocal\backup\config.done.txt $Comment
    }.GetNewClosure() {
        (Get-Content C:\BenLocal\backup\config.done.txt -ErrorAction Ignore) -contains $Comment
    } -RequiresReboot:$RequiresReboot
}

function Write-ManualStep([string]$Comment) {
    $esc = [char]27
    Write-Output "$esc[1;43;22;30;52mManual step:$esc[0;1;33m $Comment$esc[0m"
    Start-Sleep -Seconds ([Math]::Ceiling($Comment.Length / 10))
}

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
