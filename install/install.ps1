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
}

Block "Install Everything" {
    scoop install everything
    Stop-Process -Name Everything -ErrorAction Ignore
    Copy-Item $PSScriptRoot\..\programs\Everything.ini $env:UserProfile\scoop\persist\everything\Everything.ini -Force
    Create-Shortcut -Target "$env:UserProfile\scoop\apps\everything\current\Everything.exe" -Link "$env:AppData\Microsoft\Windows\Start Menu\Programs\Startup\Everything.lnk" -Arguments "-startup"
    everything -startup
}

Block "Install Slack" {
    scoop install slack
    if (& $configure $forWork) {
        Create-Shortcut -Target "$env:UserProfile\scoop\apps\slack\current\slack.exe" -Link "$env:AppData\Microsoft\Windows\Start Menu\Programs\Startup\Slack.lnk"
    }
    slack | Out-Null
}

Block "Install AutoHotkey" {
    scoop install autohotkey-installer
}

Block "Install Sysinternals" {
    scoop install sysinternals
}

Block "Install dotnet" {
    scoop install dotnet-sdk
}

Block "Install Java and Scala" {
    scoop bucket add java
    scoop install adopt8-hotspot -a 32bit # Java 1.8 JDK; Metals for VS Code does not work with 64-bit
    scoop install sbt scala # Scala
}

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
