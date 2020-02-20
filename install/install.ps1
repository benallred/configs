Block "Install Edge (Dev)" {
    iwr "https://go.microsoft.com/fwlink/?linkid=2069324&Channel=Dev&language=en&Consent=1" -OutFile $env:tmp\MicrosoftEdgeSetupDev.exe
    . $env:tmp\MicrosoftEdgeSetupDev.exe
} {
    (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*).DisplayName -eq "Microsoft Edge Dev"
}

Block "Install Authy" {
    iwr "https://electron.authy.com/download?channel=stable&arch=x64&platform=win32&version=latest&product=authy" -OutFile "$env:tmp\Authy Desktop Setup.exe"
    . "$env:tmp\Authy Desktop Setup.exe"
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

InstallFromScoopBlock nvm nvm {
    nvm install latest
    nvm use (nvm list)
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

Block "Install Visual Studio" {
    # https://visualstudio.microsoft.com/downloads/
    iwr "https://download.visualstudio.microsoft.com/download/pr/378e5eb4-c1d7-4c05-8f5f-55678a94e7f4/bace7d50d04acb355cf67ea7bb2ef7da7ceca883d3282f9a6544cb48579cc2a2/vs_Professional.exe" -OutFile $env:tmp\vs_professional.exe
    # https://docs.microsoft.com/en-us/visualstudio/install/workload-and-component-ids?view=vs-2019
    # Microsoft.VisualStudio.Workload.ManagedDesktop    .NET desktop development
    # Microsoft.VisualStudio.Workload.NetWeb            ASP.NET and web development
    # Microsoft.VisualStudio.Workload.NetCoreTools      .NET Core cross-platform development
    . $env:tmp\vs_professional.exe --passive --norestart --includeRecommended --add Microsoft.VisualStudio.Workload.ManagedDesktop --add Microsoft.VisualStudio.Workload.NetWeb --add Microsoft.VisualStudio.Workload.NetCoreTools
} {
    (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*).DisplayName -eq "Visual Studio Professional 2019"
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
