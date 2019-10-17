git config --global --add include.path $PSScriptRoot\git\ben.gitconfig

& .\install\install.ps1
& .\powershell\config.ps1
& .\windows\config.ps1

start powershell
