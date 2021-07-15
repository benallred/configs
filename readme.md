# configs

```powershell
Set-ExecutionPolicy RemoteSigned -Force
iwr -useb get.scoop.sh | iex
scoop install git-with-openssh
git clone https://github.com/benallred/configs.git C:\BenLocal\git\configs
Invoke-Expression "& { $(Invoke-RestMethod 'https://aka.ms/install-powershell.ps1') } -UseMSI -Quiet"
Invoke-Command {
    $asset = (iwr -useb https://api.github.com/repos/microsoft/winget-cli/releases/latest | ConvertFrom-Json).assets | ? { $_.name -like "*.msixbundle" }
    $downloadUrl = $asset | select -exp browser_download_url
    $fileName = $asset | select -exp name
    iwr ($downloadUrl) -OutFile $env:tmp\$fileName
    Add-AppPackage $env:tmp\$fileName
}
winget install Microsoft.WindowsTerminal
start pwsh "-NoExit", "-WindowStyle", "Maximized", "-File", "C:\BenLocal\git\configs\config.ps1"
```
