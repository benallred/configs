$src = (Resolve-Path "$PSScriptRoot\..\..")

scoop install concfg
concfg import vs-code-dark-plus -n
concfg clean

Install-Module posh-git
Add-PoshGitToProfile -AllHosts

mkdir "C:\BenLocal\PowerShell Transcripts" -ErrorAction Ignore

if (!(Test-Path $profile) -or !(Select-String "$src\\configs\\powershell\\profile.ps1" $profile))
{
	Add-Content -Path $profile -Value "`n. $src\configs\powershell\profile.ps1"
}

. $profile

Update-Help
