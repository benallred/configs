function DeleteDesktopShortcut([string]$ShortcutName) {
    $fileName = "Delete desktop shortcut $ShortcutName"
    Set-Content "$env:tmp\$fileName.ps1" {
        Write-Output "$fileName"
        Remove-Item "$env:Public\Desktop\$ShortcutName.lnk" -ErrorAction Ignore
        Remove-Item "$env:UserProfile\Desktop\$ShortcutName.lnk" -ErrorAction Ignore
    }.ToString().Replace('$fileName', $fileName).Replace('$ShortcutName', $ShortcutName)
    Create-RunOnce $fileName "powershell -File `"$env:tmp\$fileName.ps1`""
}

function InstallFollowup([string]$ProgramName, [scriptblock]$Followup) {
    $fileName = "Finish $ProgramName Install"
    Set-Content "$env:tmp\$fileName.ps1" {
        Write-Output "$fileName"
        $Followup
        Write-Output "Done. Press Enter to close."
        Read-Host
    }.ToString().Replace('$fileName', $fileName).Replace('$Followup', $Followup)
    Create-RunOnce $fileName "powershell -File `"$env:tmp\$fileName.ps1`""
}

FirstRunBlock "Configure OneNote" {
    Write-ManualStep "Start OneNote notebooks syncing"
    start onenote:
}

Block "Install Edge (Dev)" {
    iwr "https://go.microsoft.com/fwlink/?linkid=2069324&Channel=Dev&language=en&Consent=1" -OutFile $env:tmp\MicrosoftEdgeSetupDev.exe
    . $env:tmp\MicrosoftEdgeSetupDev.exe
    DeleteDesktopShortcut "Microsoft Edge Dev"
} {
    Test-ProgramInstalled "Microsoft Edge Dev"
}

Block "Install Authy" {
    iwr "https://electron.authy.com/download?channel=stable&arch=x64&platform=win32&version=latest&product=authy" -OutFile "$env:tmp\Authy Desktop Setup.exe"
    . "$env:tmp\Authy Desktop Setup.exe"
    DeleteDesktopShortcut "Authy Desktop"
} {
    Test-ProgramInstalled "Authy Desktop"
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

InstallFromScoopBlock OpenVPN openvpn {
    $openvpnExe = "$env:UserProfile\scoop\apps\openvpn\current\bin\openvpn-gui.exe"
    TestPathOrNewItem "HKCU:\Software\OpenVPN-GUI"
    Set-ItemProperty "HKCU:\Software\OpenVPN-GUI" -Name silent_connection -Value 1
    $ovpnFile = Read-Host "Path to .ovpn file"
    Copy-Item $ovpnFile $env:UserProfile\scoop\persist\openvpn\config
    New-Item "$env:AppData\Microsoft\Windows\Start Menu\Programs\BenCommands" -ItemType Directory -Force
    Create-Shortcut $openvpnExe "$env:AppData\Microsoft\Windows\Start Menu\Programs\BenCommands\vpnstart.lnk" "--connect $(Split-Path $ovpnFile -Leaf)"
    Create-Shortcut $openvpnExe "$env:AppData\Microsoft\Windows\Start Menu\Programs\BenCommands\vpnstop.lnk" "-WindowStyle Hidden `". '$openvpnExe' --command disconnect_all; . '$openvpnExe' --command exit`""
}

InstallFromScoopBlock .NET dotnet-sdk

Block "Install Java and Scala" {
    if ((& $configure $forWork) -or (& $configure $forTest)) {
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
    New-Item $env:AppData\Code\User -ItemType Directory -Force
    $token = SecureRead-Host "GitHub token for VS Code Settings Sync"
    Set-Content $env:AppData\Code\User\syncLocalSettings.json "{`"token`":`"$token`",`"autoUploadDelay`":300}"
    $gistId = Read-Host "Gist Id for VS Code Settings Sync"
    Set-Content $env:AppData\Code\User\settings.json "{`"sync.gist`":`"$gistId`",`"sync.autoDownload`":true}"
    Write-ManualStep "Monitor sync status in Output (ctrl+shift+u) > Code Settings Sync"
    code
}

Block "Install Visual Studio" {
    # https://visualstudio.microsoft.com/downloads/
    $downloadUrl = (iwr "https://visualstudio.microsoft.com/thank-you-downloading-visual-studio/?sku=Professional&rel=16" -useb | sls "https://download\.visualstudio\.microsoft\.com/download/pr/.+?/vs_Professional.exe").Matches.Value
    iwr $downloadUrl -OutFile $env:tmp\vs_professional.exe
    # https://docs.microsoft.com/en-us/visualstudio/install/workload-and-component-ids?view=vs-2019
    # Microsoft.VisualStudio.Workload.ManagedDesktop    .NET desktop development
    # Microsoft.VisualStudio.Workload.NetWeb            ASP.NET and web development
    # Microsoft.VisualStudio.Workload.NetCoreTools      .NET Core cross-platform development
    . $env:tmp\vs_professional.exe --passive --norestart --includeRecommended --add Microsoft.VisualStudio.Workload.ManagedDesktop --add Microsoft.VisualStudio.Workload.NetWeb --add Microsoft.VisualStudio.Workload.NetCoreTools
    InstallFollowup "Visual Studio" {
        . (. "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -property productPath) $PSCommandPath
        while (!(Get-ChildItem "HKCU:\Software\Microsoft\VisualStudio" | ? { $_.PSChildName -match "^\d\d.\d_" })) { sleep -s 10 }
        & "$git\configs\programs\Visual Studio - Hide dynamic nodes in Solution Explorer.ps1"
    }
} {
    Test-ProgramInstalled "Visual Studio Professional 2019"
}

Block "Install ReSharper" {
    $resharperJson = (iwr "https://data.services.jetbrains.com/products/releases?code=RSU&latest=true&type=release" -useb | ConvertFrom-Json)
    $downloadUrl = $resharperJson.RSU[0].downloads.windows.link
    $fileName = Split-Path $downloadUrl -Leaf
    iwr $downloadUrl -OutFile $env:tmp\$fileName
    . $env:tmp\$fileName /SpecificProductNames=ReSharper /VsVersion=16.0 /Silent=True
    # ReSharper command line activation not currently available:
    #   https://resharper-support.jetbrains.com/hc/en-us/articles/206545049-Can-I-enter-License-Key-License-Server-URL-via-Command-Line-when-installing-ReSharper-
} {
    Test-ProgramInstalled "JetBrains ReSharper Ultimate in Visual Studio Professional 2019"
}

Block "Install Docker" {
    if (& $configure $forTest) {
        return
    }
    # https://github.com/docker/docker.github.io/issues/6910#issuecomment-403502065
    iwr https://download.docker.com/win/stable/Docker%20for%20Windows%20Installer.exe -OutFile "$env:tmp\Docker for Windows Installer.exe"
    # https://github.com/docker/for-win/issues/1322
    . "$env:tmp\Docker for Windows Installer.exe" install --quiet | Out-Default
    Remove-Item "$env:UserProfile\Desktop\Docker Desktop.lnk"
} {
    Test-ProgramInstalled "Docker Desktop"
} -RequiresReboot

InstallFromScoopBlock AutoHotkey autohotkey-installer

Block "Install Slack" {
    iwr https://downloads.slack-edge.com/releases_x64/SlackSetup.exe -OutFile $env:tmp\SlackSetup.exe
    . $env:tmp\SlackSetup.exe
    if (!(& $configure $forWork)) {
        while (!(Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name com.squirrel.slack.slack -ErrorAction Ignore)) { sleep -s 10 }
        Remove-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name com.squirrel.slack.slack
    }
    DeleteDesktopShortcut Slack
} {
    Test-ProgramInstalled Slack
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

Block "Install Steam" {
    iwr https://steamcdn-a.akamaihd.net/client/installer/SteamSetup.exe -OutFile $env:tmp\SteamSetup.exe
    . $env:tmp\SteamSetup.exe
    DeleteDesktopShortcut Steam
} {
    Test-ProgramInstalled "Steam"
}

Block "Install Battle.net" {
    iwr https://www.battle.net/download/getInstallerForGame -OutFile $env:tmp\Battle.net-Setup.exe
    . $env:tmp\Battle.net-Setup.exe
    DeleteDesktopShortcut Battle.net
} {
    Test-ProgramInstalled "Battle.net"
}
