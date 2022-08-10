# profile timing start
$psLoadDurations += @{ name = 'Ben'; path = $PSCommandPath; stopwatch = [Diagnostics.Stopwatch]::StartNew() }
# profile timing end

$benProfileDurations = @()
$benProfileStopwatch = [Diagnostics.Stopwatch]::StartNew()
function TimeBenProfile([string]$Description) {
    $script:benProfileDurations += @{
        desc         = "Ben:$Description"
        totalTilNow  = $benProfileStopwatch.ElapsedMilliseconds
        milliseconds = $benProfileStopwatch.ElapsedMilliseconds - ($benProfileDurations.Length ? $benProfileDurations[-1].totalTilNow : 0)
    }
}

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

function Get-FunctionContents([Parameter(Mandatory)][string]$FunctionName) {
    Get-Command $FunctionName | select -exp ScriptBlock
}

function Create-Shortcut([Parameter(Mandatory)][string]$Target, [Parameter(Mandatory)][string]$Link, [string]$Arguments) {
    $dir = Split-Path $Link
    if (!(Test-Path $dir)) {
        New-Item $dir -ItemType Directory -Force | Out-Null
    }
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

function Get-SafeFileName([Parameter(Mandatory)][string]$FileName) {
    $invalidFileNameChars = [Regex]::Escape([IO.Path]::GetInvalidFileNameChars() -join "")
    $FileName -replace "[$invalidFileNameChars]", ""
}

function Copy-Item2([Parameter(Mandatory)][string[]]$Path, [string]$Destination) {
    $destinationDir = Split-Path $Destination
    if (!(Test-Path $destinationDir)) {
        New-Item $destinationDir -ItemType Directory -Force | Out-Null
    }
    Copy-Item $Path $Destination
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

function Download-File([Parameter(Mandatory)][string]$Uri, [Parameter(Mandatory)][string]$OutFile, [switch]$AutoDetermineExtension) {
    $savedProgressPreference = $ProgressPreference
    $ProgressPreference = "SilentlyContinue"
    if ($AutoDetermineExtension) {
        $contentType = (Invoke-WebRequest $Uri -Method Head).Headers["Content-Type"]
        $ext = switch ($contentType) {
            "image/jpeg" { ".jpg" }
            "image/png" { ".png" }
            Default { throw "Unknown content type `"$contentType`"" }
        }
        $OutFile += $ext
    }
    Write-Host "Downloading $Uri`n`tto $OutFile"
    $downloadFolder = Split-Path $OutFile
    if (!(Test-Path $downloadFolder)) {
        New-Item $downloadFolder -ItemType Directory -Force | Out-Null
    }
    Invoke-WebRequest $Uri -OutFile $OutFile -MaximumRetryCount 3 -RetryIntervalSec 30
    $ProgressPreference = $savedProgressPreference
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

function GitAudit([switch]$ReturnSuccess) {
    $script:GitAudit_success = $true
    function CheckDir($dir) {
        if (Test-Path (Join-Path $dir .git)) {
            pushd $dir
            $unsynced = git unsynced
            $status = git status --porcelain
            if ($unsynced -or $status) {
                $script:GitAudit_success = $false
                Write-Host ('*' * 100)
                Write-Host $dir -ForegroundColor Red
                git unsynced | Write-Host
                git status --porcelain | Write-Host
            }
            popd
        }
        elseif (Test-Path $dir -PathType Container) {
            $script:GitAudit_success = $false
            Write-Host $dir -ForegroundColor Red
            Write-Host "`tNot in source control"
        }
    }
    (Get-ChildItem $git) +
    (Get-ChildItem C:\Work -ErrorAction Ignore | Get-ChildItem) |
    % { CheckDir $_.FullName }
    if ($ReturnSuccess) {
        return $script:GitAudit_success
    }
}

function ReallyUpdate-Module([Parameter(Mandatory)][string]$Name) {
    Update-Module $Name -Force

    Remove-Module $Name
    Import-Module $Name

    Get-Module $Name -ListAvailable |
    sort Version -Descending |
    select -Skip 1 |
    % { Uninstall-Module $Name -RequiredVersion $_.Version }
}

function dotnet-really-clean() {
    if (!(Get-ChildItem *.sln)) {
        Write-Error "Not a dotnet project"
        return
    }

    Write-Output "Clearing NuGet caches"
    dotnet nuget locals all --clear | % { Write-Output "`t$_" }

    Write-Output "Removing ``packages`` directory"
    Remove-Item packages -Recurse -Force -ErrorAction Ignore

    Write-Output "Removing ``TestResults`` directory"
    Remove-Item TestResults -Recurse -Force -ErrorAction Ignore

    Write-Output "Removing ``bin`` and ``obj`` directories"
    Get-ChildItem bin, obj -Directory -Recurse |
    sort |
    % {
        Write-Output "`t$(Resolve-Path $_ -Relative)"
        Remove-Item $_ -Recurse -Force
    }
}

function winget-manifest([Parameter(Mandatory)][string]$AppId) {
    $shardLetter = $AppId.ToLower()[0]
    $path = $AppId -replace "\.", "/"
    $version = (winget show $AppId | sls "(?<=Version: ).*").Matches.Value
    $manifestUrl = "https://raw.githubusercontent.com/microsoft/winget-pkgs/master/manifests/$shardLetter/$path/$version/$AppId.installer.yaml"
    Write-Output "Fetching from $manifestUrl"
    try {
        $response = iwr $manifestUrl
    }
    catch {
        $manifestUrl = "https://raw.githubusercontent.com/microsoft/winget-pkgs/master/manifests/$shardLetter/$path/$version/$AppId.yaml"
        Write-Output "Fetching from $manifestUrl"
        $response = iwr $manifestUrl
    }
    Write-Output $response.Content
}

function tmpfor([Parameter(Mandatory)][string]$For, [switch]$Go) {
    $dir = "$tmp\$($For)_$(Get-TimestampForFileName)"
    if ($Go) {
        mkdir $dir | Out-Null
        pushd $dir
    }
    else {
        return $dir
    }
}

function togh([Parameter(Mandatory)][string]$FilePath, [int]$BeginLine, [int]$EndLine) {
    pushd (Split-Path $FilePath)
    $remote = (git config remote.origin.url) -replace "\.git", ""
    $permalinkCommit = git rev-parse --short head
    $relativePath = git ls-files --full-name $FilePath
    popd

    $url = "$remote/blob/$permalinkCommit/$relativePath" `
        + ($BeginLine -gt 0 ? "#L$BeginLine" + ($EndLine -gt 0 ? "-L$EndLine" : "") : "")
    $url = $url -replace " ", "%20"

    Set-Clipboard $url
    Write-Host "$url`n`tadded to clipboard"
}

function awslocal([Parameter(ValueFromRemainingArguments = $true)]$Rest) {
    aws --endpoint-url=http://localhost:4566 --region us-east-1 $Rest
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

TimeBenProfile "Functions"

. $PSScriptRoot\one-liners.ps1
TimeBenProfile "One-Liners"
. $PSScriptRoot\PSReadLine.ps1
TimeBenProfile "PSReadLine"

$env:POSH_GIT_ENABLED = $true
oh-my-posh init pwsh --config $PSScriptRoot\ben.omp.json | Invoke-Expression
Enable-PoshLineError
TimeBenProfile "OMP"

$transcriptDir = "C:\BenLocal\PowerShell Transcripts"
$Transcript = "$transcriptDir\$(Get-TimestampForFileName).log"
Start-Transcript $Transcript -NoClobber -IncludeInvocationHeader
TimeBenProfile "Transcript"

($benProfileDurations `
| select desc, milliseconds `
| Format-Table desc, @{ Label = "elapsed"; Expression = { "$([int]$_.milliseconds)ms" }; Alignment = "Right" } -HideTableHeaders `
| Out-String
).Trim()

# profile timing start
$currentDuration = ($psLoadDurations | ? { $_.name -eq 'Ben' })
$currentDuration.stopwatch.Stop()
$currentDuration.elapsed = $currentDuration.stopwatch.Elapsed
# profile timing end
