$OneDrive = "$env:UserProfile\OneDrive"
$git = "C:\BenLocal\git"

$tmp = "C:\BenLocal\ToDelete\$(Get-Date -Format "yyyyMM")"

function Update-WindowsTerminalSettings() {
    Import-Module Appx -UseWindowsPowerShell
    Copy-Item $PSScriptRoot\settings.json "$env:LocalAppData\Packages\$((Get-AppxPackage -Name Microsoft.WindowsTerminal).PackageFamilyName)\LocalState\settings.json"
}

function Test-IsAdmin() {
    ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Run-AsAdmin([Parameter(Mandatory)][string]$FilePath) {
    Start-Process wt -Verb RunAs -ArgumentList "-w run-as-admin pwsh -File `"$FilePath`""
}

function Create-Shortcut([Parameter(Mandatory)][string]$Target, [Parameter(Mandatory)][string]$Link, [string]$Arguments) {
    $shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut($Link)
    $shortcut.TargetPath = $Target
    $shortcut.WorkingDirectory = Split-Path $Target
    $shortcut.Arguments = $Arguments
    $shortcut.Save()
}

function Create-RunOnce([Parameter(Mandatory)][string]$Description, [Parameter(Mandatory)][string]$Command) {
    # https://docs.microsoft.com/en-us/windows/win32/setupapi/run-and-runonce-registry-keys
    Set-RegistryValue "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name $Description -Value $Command
}

function Create-FileRunOnce([Parameter(Mandatory)][string]$Description, [Parameter(Mandatory)][string]$FilePath) {
    Create-RunOnce $Description "$((Get-Command wt).Source) -w run-once pwsh -Command `"Run-AsAdmin '$FilePath'`""
}

function Get-TimestampForFileName() {
    (Get-Date -Format o) -replace ":", "_"
}

function Set-RegistryValue([Parameter(Mandatory)][string]$Path, [string]$Name = "(Default)", [Parameter(Mandatory)][object]$Value) {
    if (!(Test-Path $Path)) {
        New-Item $Path -Force | Out-Null
    }
    Set-ItemProperty $Path -Name $Name -Value $Value
}

function Set-EnvironmentVariable([Parameter(Mandatory)][string]$Variable, [string]$Value) {
    [Environment]::SetEnvironmentVariable($Variable, $Value, "User")
    [Environment]::SetEnvironmentVariable($Variable, $Value, "Process")
}

function Get-ProgramsInstalled() {
    return (Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*).DisplayName +
    (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*).DisplayName +
    (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*).DisplayName |
    sort
}

function Test-ProgramInstalled([Parameter(Mandatory)][string]$NameLike) {
    return (Get-ProgramsInstalled) -like "*$NameLike*"
}

function SecureRead-Host([string]$Prompt) {
    $secureString = Read-Host -Prompt $Prompt -AsSecureString
    $binaryString = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString)
    $string = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($binaryString)
    return $string
}

function Download-File([Parameter(Mandatory)][string]$Uri, [Parameter(Mandatory)][string]$OutFile) {
    $savedProgressPreference = $ProgressPreference
    $ProgressPreference = "SilentlyContinue"
    Write-Host "Downloading $Uri`n`tto $OutFile"
    Invoke-WebRequest $Uri -OutFile $OutFile -MaximumRetryCount 3 -RetryIntervalSec 30
    $ProgressPreference = $savedProgressPreference
}

function AddNuGetSource([Parameter(Mandatory)][string]$Name, [Parameter(Mandatory)][string]$Path) {
    $nugetConfigPath = "$env:AppData\NuGet\nuget.config"
    if (!(Select-String $Path $nugetConfigPath)) {
        [xml]$nugetConfigXml = Get-Content $nugetConfigPath
        $newPackageSource = $nugetConfigXml.CreateElement("add")
        $newPackageSource.SetAttribute("key", $Name)
        $newPackageSource.SetAttribute("value", $Path)
        $nugetConfigXml.configuration.packageSources.AppendChild($newPackageSource)
        $nugetConfigXml.Save($nugetConfigPath)
    }
}

function Find-RepoRoot() {
    $repoRoot = Get-Location
    while (!(Test-Path $repoRoot\.git)) {
        if ($repoRoot -like "*:\") {
            throw "No git repo found between $pwd and $repoRoot"
        }
        $repoRoot = Resolve-Path "$repoRoot\.."
    }
    return $repoRoot
}

function GitAudit() {
    function CheckDir($dir) {
        pushd $dir
        if (Test-Path (Join-Path $dir .git)) {
            $unsynced = git unsynced
            $status = git status --porcelain
            if ($unsynced -or $status) {
                Write-Output (New-Object System.String -ArgumentList ('*', 100))
                Write-Host $dir -ForegroundColor Red
                git unsynced
                git status --porcelain
            }
        }
        popd
    }
    (Get-ChildItem $git) +
    (Get-ChildItem C:\Work | Get-ChildItem) |
    % { CheckDir $_.FullName }
}

function ReallyUpdate-Module([Parameter(Mandatory)][string]$Name) {
    Update-Module $Name -Force

    Get-Module $Name -ListAvailable |
    sort Version -Descending |
    select -Skip 1 |
    % { Uninstall-Module $Name -RequiredVersion $_.Version }
}

Register-ArgumentCompleter -Native -CommandName .\config.ps1 -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    if ((Get-Location).Path -ne "$git\configs") {
        return
    }

    dir $git\configs *.ps1 -Recurse |
    sls "Block `"(.+?)`"" |
    % { "`"$($_.Matches.Groups[1].Value)`"" } |
    ? { $_ -like "*$wordToComplete*" } |
    sort |
    % {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

function tmpfor([Parameter(Mandatory)][string]$For) {
    "$tmp\$($For)_$(Get-TimestampForFileName)"
}

. $PSScriptRoot\one-liners.ps1

$transcriptDir = "C:\BenLocal\PowerShell Transcripts"
Get-ChildItem "$transcriptDir\*.log" | ? { !(sls -Path $_ -Pattern "Command start time:" -SimpleMatch -Quiet) } | rm -ErrorAction SilentlyContinue
$Transcript = "$transcriptDir\$(Get-TimestampForFileName).log"
Start-Transcript $Transcript -NoClobber -IncludeInvocationHeader

Set-PoshPrompt $PSScriptRoot\ben.omp.json
