# configs

## Pre-Bootstrap

- Windows Update
- Update drivers
- `winget upgrade Microsoft.WindowsTerminal --accept-source-agreements`

## Bootstrap

```powershell
$bootstrapDuration = [Diagnostics.Stopwatch]::StartNew()
Set-ExecutionPolicy RemoteSigned -Force
winget install --id Git.Git
winget install --id Microsoft.PowerShell
$env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
git clone https://github.com/benallred/configs.git C:\BenLocal\git\configs
pwsh -NoProfile -c "Install-Module PSReadLine -Force"
Write-Output "Bootstrap duration: $($bootstrapDuration.Elapsed)"
pwsh -NoExit C:\BenLocal\git\configs\config.ps1
```
