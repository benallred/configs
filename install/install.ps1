Block "Install Edge (Dev)" {
    iwr "https://go.microsoft.com/fwlink/?linkid=2069324&Channel=Dev&language=en&Consent=1" -OutFile $env:tmp\MicrosoftEdgeSetupDev.exe
    start $env:tmp\MicrosoftEdgeSetupDev.exe
} {
    (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*).DisplayName -eq "Microsoft Edge Dev"
}

Block "Install Authy" {
    iwr "https://electron.authy.com/download?channel=stable&arch=x64&platform=win32&version=latest&product=authy" -OutFile "$env:tmp\Authy Desktop Setup.exe"
    start "$env:tmp\Authy Desktop Setup.exe"
} {
    Test-Path "$env:LocalAppData\authy-electron\Authy Desktop.exe"
}

Block "Configure scoop extras bucket" {
    scoop bucket add extras
} {
    scoop bucket list | Select-String extras
}

function InstallFromScoopBlock([string]$AppName, [string]$AppId, [scriptblock]$AfterInstall) {
    Block "Install $AppName" {
        scoop install $AppId
        if ($AfterInstall) {
            Invoke-Command $AfterInstall
        }
    } {
        scoop export | Select-String $AppId
    }
}

InstallFromScoopBlock Everything everything {
    Stop-Process -Name Everything -ErrorAction Ignore
    Copy-Item $PSScriptRoot\..\programs\Everything.ini $env:UserProfile\scoop\persist\everything\Everything.ini -Force
    Create-Shortcut -Target "$env:UserProfile\scoop\apps\everything\current\Everything.exe" -Link "$env:AppData\Microsoft\Windows\Start Menu\Programs\Startup\Everything.lnk" -Arguments "-startup"
    everything -startup
}

InstallFromScoopBlock .NET dotnet-sdk

Block "Install Java and Scala" {
    if (& $configure $forWork) {
        scoop bucket add java
        scoop install adopt8-hotspot -a 32bit # Java 1.8 JDK; Metals for VS Code does not work with 64-bit
        scoop install sbt scala # Scala
    }
} {
    scoop export | Select-String adopt8-hotspot
}

InstallFromScoopBlock "VS Code" vscode {
    code --install-extension Shan.code-settings-sync
    New-Item $env:APPDATA\Code\User -ItemType Directory -Force
    $token = SecureRead-Host "GitHub token for VS Code Settings Sync"
    Set-Content $env:APPDATA\Code\User\syncLocalSettings.json "{`"token`":`"$token`",`"autoUploadDelay`":300}"
    $gistId = Read-Host "Gist Id for VS Code Settings Sync"
    Set-Content $env:APPDATA\Code\User\settings.json "{`"sync.gist`":`"$gistId`",`"sync.autoDownload`":true}"
    Write-Host "Monitor sync status in Output (ctrl+shift+u) > Code Settings Sync" -ForegroundColor Yellow
    Start-Sleep -Seconds 3
    code
}

InstallFromScoopBlock AutoHotkey autohotkey-installer

InstallFromScoopBlock Slack slack {
    if (& $configure $forWork) {
        Create-Shortcut -Target "$env:UserProfile\scoop\apps\slack\current\slack.exe" -Link "$env:AppData\Microsoft\Windows\Start Menu\Programs\Startup\Slack.lnk"
    }
    slack | Out-Null
}

InstallFromScoopBlock Sysinternals sysinternals

function InstallFromGitHubBlock([string]$User, [string]$Repo, [scriptblock]$AfterClone) {
    Block "Install $User/$Repo" {
        git clone https://github.com/$User/$Repo.git $git\$Repo
        if ($AfterClone) {
            Invoke-Command $AfterClone
        }
    } {
        Test-Path $git\$Repo
    }
}

InstallFromGitHubBlock "benallred" "Bahk" { . $git\Bahk\Ben.ahk }

InstallFromGitHubBlock "benallred" "YouTubeToPlex"
