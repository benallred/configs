function Block([string]$Comment, [scriptblock]$ScriptBlock, [scriptblock]$CompleteCheck) {
    Write-Output (New-Object System.String -ArgumentList ('*', 100))
    Write-Output $Comment
    if ($CompleteCheck -and (Invoke-Command $CompleteCheck)) {
        Write-Output "Already done"
        return
    }
    Invoke-Command $ScriptBlock
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
. $profile # make profile available to scripts below
Block "Git config" {
    git config --global --add include.path $PSScriptRoot\git\ben.gitconfig
} {
    (git config --get-all --global include.path) -match "ben.gitconfig"
}
& $PSScriptRoot\install\install.ps1
& $PSScriptRoot\windows\config.ps1
& $PSScriptRoot\scheduled-tasks\config.ps1
