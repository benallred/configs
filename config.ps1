function Block([string]$Comment, [scriptblock]$ScriptBlock, [scriptblock]$CompleteCheck) {
    Write-Output (New-Object System.String -ArgumentList ('*', 100))
    Write-Output $Comment
    if ($CompleteCheck -and (Invoke-Command $CompleteCheck)) {
        Write-Output "Already done"
        return
    }
    Invoke-Command $ScriptBlock
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
