Block "Backup Registry" {
    & $PSScriptRoot\backup.ps1
}
Block "Rename computer" {
    Rename-Computer -NewName (Read-Host "Set computer name to")
} {
    $env:ComputerName -notlike 'desktop-*'
}
Block "Disable UAC" {
    & "$PSScriptRoot\Disable UAC.ps1"
}
& $PSScriptRoot\desktop.ps1
& $PSScriptRoot\store.ps1
& $PSScriptRoot\explorer.ps1
