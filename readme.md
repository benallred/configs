# configs

```powershell
$bootstrapDuration = [Diagnostics.Stopwatch]::StartNew()
Set-ExecutionPolicy RemoteSigned -Force
Invoke-Command {
    $asset = (iwr -useb https://api.github.com/repos/microsoft/winget-cli/releases/latest | ConvertFrom-Json).assets | ? { $_.name -like "*.msixbundle" }
    $downloadUrl = $asset | select -exp browser_download_url
    $fileName = $asset | select -exp name
    iwr ($downloadUrl) -OutFile $env:tmp\$fileName
    Add-AppPackage $env:tmp\$fileName
}
winget list winget --accept-source-agreements
winget install --id Git.Git
winget install --id Microsoft.PowerShell
winget install --id Microsoft.WindowsTerminal
$env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
git clone https://github.com/benallred/configs.git C:\BenLocal\git\configs
wt --maximized pwsh -NoExit -File C:\BenLocal\git\configs\config.ps1
Write-Output "Bootstrap duration: $($bootstrapDuration.Elapsed)"
```
