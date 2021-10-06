function Block([string]$Comment, [scriptblock]$ScriptBlock, [scriptblock]$CompleteCheck, [switch]$RequiresReboot) {
    if ($Run -and $Run -ne $Comment) {
        return
    }
    $blockDuration = [Diagnostics.Stopwatch]::StartNew()
    function Write-OrSilent([string]$Text, [System.ConsoleColor]$ForegroundColor) {
        if (!$Silent) {
            Write-Host $Text -ForegroundColor $ForegroundColor
        }
    }
    function Write-BlockDuration() {
        Write-OrSilent "Block duration: $($blockDuration.Elapsed)" Blue
    }
    Write-OrSilent ('*' * 100) DarkBlue
    Write-OrSilent $Comment DarkBlue
    if ($CompleteCheck -and (Invoke-Command $CompleteCheck)) {
        Write-OrSilent "Already done" Blue
        if (!$Run) {
            Write-BlockDuration
            return
        }
        else {
            Write-OrSilent "But running anyway as requested" Green
        }
    }
    if (!$DryRun) {
        if ($RequiresReboot) {
            Write-OrSilent "This will take effect after a reboot" Yellow
        }
        Invoke-Command $ScriptBlock
    }
    else {
        Write-OrSilent "This block would execute" Green
    }
    Write-BlockDuration
}

function FirstRunBlock([string]$Comment, [scriptblock]$ScriptBlock, [switch]$RequiresReboot) {
    Block $Comment {
        Invoke-Command $ScriptBlock
        Add-Content C:\BenLocal\backup\config.done.txt $Comment
    }.GetNewClosure() {
        (Get-Content C:\BenLocal\backup\config.done.txt -ErrorAction Ignore) -contains $Comment
    } -RequiresReboot:$RequiresReboot
}

function ConfigFollowup([string]$FileName, [scriptblock]$Followup) {
    Set-Content "$env:tmp\$FileName.ps1" {
        Write-Output "$FileName"
        . $git\configs\config-functions.ps1
        $Followup
        Write-Output "Done. Press Enter to close."
        Read-Host
    }.ToString().Replace('$FileName', $FileName).Replace('$Followup', $Followup)
    Create-FileRunOnce $FileName "$env:tmp\$FileName.ps1"
}

function WaitWhile([scriptblock]$ScriptBlock, [string]$WaitingFor) {
    while (Invoke-Command $ScriptBlock) {
        Write-Host -ForegroundColor Yellow $WaitingFor
        sleep -s 10
    }
}

function WaitForPath([string]$Path) {
    WaitWhile { !(Test-Path $Path) } "Waiting for path $Path"
}

function WaitWhileProcess([string]$ProcessName) {
    WaitWhile { Get-Process $ProcessName -ErrorAction Ignore } "Waiting for $ProcessName to close"
}

function Write-ManualStep([string]$Comment) {
    $esc = [char]27
    Write-Output "$esc[1;43;22;30;52mManual step:$esc[0;1;33m $Comment$esc[0m"
    Start-Sleep -Seconds ([Math]::Ceiling($Comment.Length / 10))
}

function ConfigureNotifications([string]$ProgramName) {
    WaitWhileProcess SystemSettings
    Write-ManualStep "Configure notifications for: $ProgramName"
    start ms-settings:notifications
    Write-ManualStep "`tShow notifications in action center = Off"
    Write-ManualStep "`tClose settings when done"
}

function DeleteDesktopShortcut([string]$ShortcutName) {
    $fileName = "Delete desktop shortcut $ShortcutName"
    Set-Content "$env:tmp\$fileName.ps1" {
        Write-Output "$fileName"
        Remove-Item "$env:Public\Desktop\$ShortcutName.lnk" -ErrorAction Ignore
        Remove-Item "$env:UserProfile\Desktop\$ShortcutName.lnk" -ErrorAction Ignore
    }.ToString().Replace('$fileName', $fileName).Replace('$ShortcutName', $ShortcutName)
    Create-FileRunOnce $fileName "$env:tmp\$fileName.ps1"
}

function InstallFromGitHubBlock([string]$User, [string]$Repo, [scriptblock]$AfterClone, [int]$CloneDepth) {
    Block "Install $User/$Repo" {
        if (!$CloneDepth) {
            git clone https://github.com/$User/$Repo.git $git\$Repo
        }
        else {
            git clone https://github.com/$User/$Repo.git $git\$Repo --depth $CloneDepth
        }
        if ($AfterClone) {
            pushd $git\$Repo
            Invoke-Command $AfterClone
            popd
        }
    } {
        Test-Path $git\$Repo
    }
}

function InstallFromGitHubAssetBlock([string]$User, [string]$Repo, [string]$Asset, [scriptblock]$Install, [scriptblock]$CompleteCheck) {
    Block "Install $User/$Repo/$Asset" {
        $asset = (iwr https://api.github.com/repos/$User/$Repo/releases/latest | ConvertFrom-Json).assets | ? { $_.name -like $Asset }
        $downloadUrl = $asset | select -exp browser_download_url
        $fileName = $asset | select -exp name
        Download-File $downloadUrl $env:tmp\$fileName
        if ($fileName -like "*.zip") {
            Expand-Archive $env:tmp\$fileName $env:tmp\$Repo
        }
        else {
            mkdir $env:tmp\$Repo
            mv $env:tmp\$fileName $env:tmp\$Repo\$fileName
        }
        pushd $env:tmp\$Repo
        Invoke-Command $Install
        popd
    } $CompleteCheck
}

function InstallFromWingetBlock {
    [CmdletBinding(DefaultParameterSetName = "DefaultArgs")]
    Param(
        [Parameter(ParameterSetName = "DefaultArgs", Mandatory, Position = 0)]
        [Parameter(ParameterSetName = "OverrideArgs", Mandatory, Position = 0)]
        [string]$AppId,
        [Parameter(ParameterSetName = "OverrideArgs", Position = 1)]
        [string]$OverrideArgs,
        [Parameter(ParameterSetName = "DefaultArgs", Position = 1)]
        [Parameter(ParameterSetName = "OverrideArgs", Position = 2)]
        [scriptblock]$AfterInstall)
    Block "Install $AppId" {
        if ($OverrideArgs) {
            winget install --id $AppId --override $OverrideArgs
        }
        else {
            winget install --id $AppId
        }
        $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
        if ($AfterInstall) {
            Invoke-Command $AfterInstall
        }
    } {
        winget list $AppId -e | sls $AppId
    }
}

function InstallFromScoopBlock([string]$AppName, [string]$AppId, [scriptblock]$AfterInstall) {
    Block "Install $AppName" {
        scoop install $AppId
        if ($AfterInstall) {
            Invoke-Command $AfterInstall
        }
    } {
        scoop export | sls $AppId
    }
}

# Get AppName with
#   Get-StartApps name
# Get ProductId by searching for app at
#   https://www.microsoft.com/en-us/search
# Get AppPackageName with
#   (Get-AppxPackage -Name "*name*").Name
function InstallFromMicrosoftStoreBlock([string]$AppName, [string]$ProductId, [string]$AppPackageName) {
    Block "Install $AppName" {
        Write-ManualStep "Install $AppName"
        start ms-windows-store://pdp/?ProductId=$ProductId
        WaitWhile { !(Get-AppxPackage -Name $AppPackageName) } "Waiting for $AppName to be installed"
        start "shell:AppsFolder\$(Get-StartApps $AppName | ? { $_.Name -eq $AppName } | select -ExpandProperty AppId)"
    } {
        Import-Module Appx -UseWindowsPowerShell
        Get-AppxPackage -Name $AppPackageName
    }
}
