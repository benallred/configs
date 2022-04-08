# configs

## Pre-Bootstrap

- Windows Update
- Update drivers
- ```powershell
  start ms-windows-store://pdp/?ProductId=9NBLGGH4NNS1
  while (!(Get-Command winget -ErrorAction Ignore)) {
    Write-Output "Waiting for App Installer update"
    sleep -s 5
  }
  winget upgrade Microsoft.WindowsTerminal --accept-source-agreements
  ```

## Bootstrap

```powershell
$bootstrapDuration = [Diagnostics.Stopwatch]::StartNew()
Set-ExecutionPolicy RemoteSigned -Force
winget install --id Git.Git
winget install --id Microsoft.PowerShell
$env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
git clone https://github.com/benallred/configs.git C:\BenLocal\git\configs
Write-Output "Bootstrap duration: $($bootstrapDuration.Elapsed)"
pwsh -NoExit C:\BenLocal\git\configs\config.ps1
```
