# configs

```powershell
Set-ExecutionPolicy RemoteSigned -Force
Invoke-Command {
    $asset = (iwr -useb https://api.github.com/repos/microsoft/winget-cli/releases/latest | ConvertFrom-Json).assets | ? { $_.name -like "*.msixbundle" }
    $downloadUrl = $asset | select -exp browser_download_url
    $fileName = $asset | select -exp name
    iwr ($downloadUrl) -OutFile $env:tmp\$fileName
    Add-AppPackage $env:tmp\$fileName
}
winget install Git.Git
winget install Microsoft.PowerShell
winget install Microsoft.WindowsTerminal
$env:Path = "$env:Path;$env:ProgramFiles\Git\cmd;$env:ProgramFiles\PowerShell\7"
git clone https://github.com/benallred/configs.git C:\BenLocal\git\configs
wt --maximized pwsh -NoExit -File C:\BenLocal\git\configs\config.ps1
```
