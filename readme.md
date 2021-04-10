# configs

```powershell
Set-ExecutionPolicy RemoteSigned -Force
iwr -useb get.scoop.sh | iex
scoop install git-with-openssh
git clone https://github.com/benallred/configs.git C:\BenLocal\git\configs
cd C:\BenLocal\git\configs
. .\config-functions.ps1
InstallFromMicrosoftStoreBlock PowerShell 9mz1snwt0n5d Microsoft.PowerShell
start pwsh -ArgumentList "-NoExit", "-WindowStyle", "Maximized", "-File", ".\config.ps1"
```
