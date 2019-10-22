& .\backup.ps1
Rename-Computer -NewName (Read-Host "Set computer name to")
& '.\windows\Disable UAC.ps1'
& .\desktop.ps1
& .\store.ps1
& .\explorer.ps1
