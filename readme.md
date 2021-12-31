# configs

## Pre-Bootstrap

- Windows Update
- Update drivers
- `winget upgrade Microsoft.WindowsTerminal`

## Bootstrap

```powershell
$bootstrapDuration = [Diagnostics.Stopwatch]::StartNew()
Set-ExecutionPolicy RemoteSigned -Force
winget list winget --accept-source-agreements
winget install --id Git.Git
winget install --id Microsoft.PowerShell
$env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
git clone https://github.com/benallred/configs.git C:\BenLocal\git\configs
Write-Output "Bootstrap duration: $($bootstrapDuration.Elapsed)"
pwsh -NoExit C:\BenLocal\git\configs\config.ps1
```
