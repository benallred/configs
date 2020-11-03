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

function InstallFromMicrosoftStoreBlock([string]$AppName, [string]$ProductId, [string]$AppPackageName) {
    Block "Install $AppName" {
        Write-ManualStep "Install $AppName"
        start ms-windows-store://pdp/?ProductId=$ProductId
        while (!(Get-AppxPackage -Name $AppPackageName)) { sleep -s 10 }
        start "shell:AppsFolder\$(Get-StartApps $AppName | select -ExpandProperty AppId)"
    } {
        Get-AppxPackage -Name $AppPackageName
    }
}

Block "Configure scoop extras bucket" {
    scoop bucket add extras
} {
    scoop bucket list | Select-String extras
}

Block "Configure scoop nonportable bucket" {
    scoop bucket add nonportable
} {
    scoop bucket list | Select-String nonportable
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

InstallFromScoopBlock Everything everything {
    Copy-Item $PSScriptRoot\..\programs\Everything.ini (scoop prefix everything)
    everything -install-run-on-system-startup
    everything -startup
}

InstallFromScoopBlock OpenVPN openvpn {
    $openvpnExe = "$env:UserProfile\scoop\apps\openvpn\current\bin\openvpn-gui.exe"
    $ovpnFile = (Read-Host "Path to .ovpn file").Trim('"')
    Copy-Item $ovpnFile $env:UserProfile\scoop\persist\openvpn\config
    New-Item "$env:AppData\Microsoft\Windows\Start Menu\Programs\BenCommands" -ItemType Directory -Force
    Create-Shortcut $openvpnExe "$env:AppData\Microsoft\Windows\Start Menu\Programs\BenCommands\vpnstart.lnk" "--connect $(Split-Path $ovpnFile -Leaf)"
    Create-Shortcut powershell "$env:AppData\Microsoft\Windows\Start Menu\Programs\BenCommands\vpnstop.lnk" "-WindowStyle Hidden `". '$openvpnExe' --command disconnect_all; . '$openvpnExe' --command exit`""
    . "$env:AppData\Microsoft\Windows\Start Menu\Programs\BenCommands\vpnstart.lnk"
    while (!(Test-Path "HKCU:\Software\OpenVPN-GUI")) { sleep -s 10 }
    Set-ItemProperty "HKCU:\Software\OpenVPN-GUI" -Name silent_connection -Value 1
    ConfigureNotifications "OpenVPN GUI for Windows"
    if (!(& $configure $forWork)) {
        . "$env:AppData\Microsoft\Windows\Start Menu\Programs\BenCommands\vpnstop.lnk"
    }
}

InstallFromScoopBlock .NET dotnet-sdk

if ((& $configure $forWork) -or (& $configure $forTest)) {
    Block "Configure scoop java bucket and install Java" {
        scoop bucket add java
        scoop install adopt8-hotspot -a 32bit # Java 1.8 JDK; Metals for VS Code does not work with 64-bit
    } {
        scoop export | Select-String adopt8-hotspot
    }
    InstallFromScoopBlock SBT sbt
    InstallFromScoopBlock Scala scala

    InstallFromScoopBlock Postgres postgresql
    InstallFromGitHubBlock pluralsight psqlx {
        if (!(Test-Path $profile) -or !(Select-String "psqlx\.ps1" $profile)) {
            Add-Content -Path $profile -Value "`n"
            Add-Content -Path $profile -Value "`$psqlxRunner = `"psql`" # or `"docker`""
            Add-Content -Path $profile -Value ". $git\psqlx\psqlx.ps1"
        }
    }
}

InstallFromScoopBlock nvm nvm {
    nvm install latest
    nvm use (nvm list)
}

InstallFromScoopBlock Yarn yarn

Block "Install VS Code" {
    iwr https://aka.ms/win32-x64-user-stable -OutFile $env:tmp\VSCodeUserSetup-x64.exe
    . $env:tmp\VSCodeUserSetup-x64.exe /SILENT /TASKS="associatewithfiles,addtopath" /LOG=$env:tmp\VSCodeInstallLog.txt
    while (!(Test-ProgramInstalled "Visual Studio Code")) { sleep -s 10 }
    $codeCmd = "$env:LocalAppData\Programs\Microsoft VS Code\bin\code.cmd"
    . $codeCmd --install-extension shan.code-settings-sync
    New-Item $env:AppData\Code\User -ItemType Directory -Force
    $token = SecureRead-Host "GitHub token for VS Code Settings Sync"
    Set-Content $env:AppData\Code\User\syncLocalSettings.json "{`"token`":`"$token`",`"autoUploadDelay`":300}"
    $gistId = Read-Host "Gist Id for VS Code Settings Sync"
    Set-Content $env:AppData\Code\User\settings.json "{`"sync.gist`":`"$gistId`",`"sync.autoDownload`":true}"
    Write-ManualStep "Monitor sync status in Output (ctrl+shift+u) > Code Settings Sync"
    . $codeCmd
} {
    Test-ProgramInstalled "Microsoft Visual Studio Code (User)"
}

Block "Install Visual Studio" {
    # https://visualstudio.microsoft.com/downloads/
    $downloadUrl = (iwr "https://visualstudio.microsoft.com/thank-you-downloading-visual-studio/?sku=Professional&rel=16" -useb | sls "https://download\.visualstudio\.microsoft\.com/download/pr/.+?/vs_Professional.exe").Matches.Value
    iwr $downloadUrl -OutFile $env:tmp\vs_professional.exe
    # https://docs.microsoft.com/en-us/visualstudio/install/workload-and-component-ids?view=vs-2019
    # Microsoft.VisualStudio.Workload.ManagedDesktop    .NET desktop development
    # Microsoft.VisualStudio.Workload.NetWeb            ASP.NET and web development
    # Microsoft.VisualStudio.Workload.NetCoreTools      .NET Core cross-platform development
    # https://docs.microsoft.com/en-us/visualstudio/install/command-line-parameter-examples?view=vs-2019#using---wait
    $vsInstallArgs = '--passive', '--norestart', '--wait', '--includeRecommended', '--add', 'Microsoft.VisualStudio.Workload.ManagedDesktop', '--add', 'Microsoft.VisualStudio.Workload.NetWeb', '--add', 'Microsoft.VisualStudio.Workload.NetCoreTools'
    Start-Process $env:tmp\vs_professional.exe $vsInstallArgs -Wait -PassThru
    InstallFollowup "Visual Studio" {
        . (. "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -property productPath) $PSCommandPath
        while (!(Get-ChildItem "HKCU:\Software\Microsoft\VisualStudio" | ? { $_.PSChildName -match "^\d\d.\d_" })) { sleep -s 10 }
        & "$git\configs\programs\Visual Studio - Hide dynamic nodes in Solution Explorer.ps1"
    }
    
    function InstallVisualStudioExtension([string]$Publisher, [string]$Extension) {
        $downloadUrl = (iwr "https://marketplace.visualstudio.com/items?itemName=$Publisher.$Extension" -useb | sls "/_apis/public/gallery/publishers/$Publisher/vsextensions/$Extension/(\d+\.?)+/vspackage").Matches.Value | % { "https://marketplace.visualstudio.com$_" }
        iwr $downloadUrl -OutFile $env:tmp\$Publisher.$Extension.vsix
        $vsixInstaller = . "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -property productPath | Split-Path | % { "$_\VSIXInstaller.exe" }
        . $vsixInstaller /quiet /admin $env:tmp\$Publisher.$Extension.vsix
    }

    InstallVisualStudioExtension VisualStudioPlatformTeam SolutionErrorVisualizer
    InstallVisualStudioExtension VisualStudioPlatformTeam FixMixedTabs
    InstallVisualStudioExtension VisualStudioPlatformTeam PowerCommandsforVisualStudio
} {
    Test-ProgramInstalled "Visual Studio Professional 2019"
}

Block "Install ReSharper" {
    $resharperJson = (iwr "https://data.services.jetbrains.com/products/releases?code=RSU&latest=true&type=release" -useb | ConvertFrom-Json)
    $downloadUrl = $resharperJson.RSU[0].downloads.windows.link
    $fileName = Split-Path $downloadUrl -Leaf
    iwr $downloadUrl -OutFile $env:tmp\$fileName
    . $env:tmp\$fileName /SpecificProductNames=ReSharper /VsVersion=16.0 /Silent=True
    # Activation:
    #   ReSharper command line activation not currently available:
    #   https://resharper-support.jetbrains.com/hc/en-us/articles/206545049-Can-I-enter-License-Key-License-Server-URL-via-Command-Line-when-installing-ReSharper-
    # Settings:
    #   No CLI that I can find to import settings file
    #   It might be roamed?
    #   Or try editing $env:AppData\JetBrains\Shared\vAny\GlobalSettingsStorage.DotSettings
    #       <s:Boolean x:Key="/Default/Environment/InjectedLayers/FileInjectedLayer/=8232C3A8D8B5804BBE2C12625C76862A/@KeyIndexDefined">True</s:Boolean>
    #       <s:String x:Key="/Default/Environment/InjectedLayers/FileInjectedLayer/=8232C3A8D8B5804BBE2C12625C76862A/AbsolutePath/@EntryValue">C:\BenLocal\git\configs\programs\resharper.DotSettings</s:String>
    #       <s:Boolean x:Key="/Default/Environment/InjectedLayers/InjectedLayerCustomization/=File8232C3A8D8B5804BBE2C12625C76862A/@KeyIndexDefined">True</s:Boolean>
    #       <s:Double x:Key="/Default/Environment/InjectedLayers/InjectedLayerCustomization/=File8232C3A8D8B5804BBE2C12625C76862A/RelativePriority/@EntryValue">1</s:Double>
    # Conflicting shortcuts
    #   Can't find a setting to disable the popup
    #   Perhaps edit $env:LocalAppData\JetBrains\ReSharper\vAny\vs16.0_ef96ec49\vsActionManager.DotSettings
    #       Remove all keys with "ConflictingActions" and corresponding "ActionsWithShortcuts"?
} {
    Test-ProgramInstalled "JetBrains ReSharper in Visual Studio Professional 2019"
}

Block "Install Docker" {
    if (& $configure $forTest) {
        return
    }
    # https://github.com/docker/docker.github.io/issues/6910#issuecomment-403502065
    iwr https://download.docker.com/win/stable/Docker%20for%20Windows%20Installer.exe -OutFile "$env:tmp\Docker for Windows Installer.exe"
    # https://github.com/docker/for-win/issues/1322
    . "$env:tmp\Docker for Windows Installer.exe" install --quiet | Out-Default
    DeleteDesktopShortcut "Docker Desktop"
    ConfigureNotifications "Docker Desktop"
} {
    Test-ProgramInstalled "Docker Desktop"
} -RequiresReboot

Block "Install AutoHotkey" {
    iwr https://www.autohotkey.com/download/ahk-install.exe -OutFile $env:tmp\ahk-install.exe
    . $env:tmp\ahk-install.exe /S /IsHostApp
} {
    Test-ProgramInstalled AutoHotkey
}

Block "Install Slack" {
    iwr https://downloads.slack-edge.com/releases_x64/SlackSetup.exe -OutFile $env:tmp\SlackSetup.exe
    . $env:tmp\SlackSetup.exe
    if (!(& $configure $forWork)) {
        while (!(Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name com.squirrel.slack.slack -ErrorAction Ignore)) { sleep -s 10 }
        Remove-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name com.squirrel.slack.slack
    }
    DeleteDesktopShortcut Slack
    ConfigureNotifications Slack
} {
    Test-ProgramInstalled Slack
}

Block "Install Office" {
    # https://www.microsoft.com/en-in/download/details.aspx?id=49117
    $downloadUrl = (iwr "https://www.microsoft.com/en-in/download/confirmation.aspx?id=49117" -useb | sls "https://download\.microsoft\.com/download/.+?/officedeploymenttool_.+?.exe").Matches.Value
    iwr $downloadUrl -OutFile $env:tmp\officedeploymenttool.exe
    . $env:tmp\officedeploymenttool.exe /extract:$env:tmp\officedeploymenttool /passive /quiet
    while (!(Test-Path $env:tmp\officedeploymenttool\setup.exe)) { sleep -s 10 }
    . $env:tmp\officedeploymenttool\setup.exe /configure $PSScriptRoot\OfficeConfiguration.xml
    # TODO: Activate
    #   Observed differences
    #       Manual install and activation
    #           Word > Account: Product Activated \ Microsoft Office Professional Plus 2019
    #           cscript "C:\Program Files (x86)\Microsoft Office\Office16\OSPP.VBS" /dstatus
    #               LICENSE NAME: Office 19, Office19ProPlus2019MSDNR_Retail edition
    #               LICENSE DESCRIPTION: Office 19, RETAIL channel
    #               LICENSE STATUS:  ---LICENSED---
    #               Last 5 characters of installed product key: <correct>
    #       Automated install (product id = Professional2019Retail), no activation
    #           Word > Account: Activation Required \ Microsoft Office Professional 2019
    #       Automated install (product id = Professional2019Retail), activation by filling in PIDKEY
    #           Word > Account: Subscription Product \ Microsoft Office 365 ProPlus
    #           cscript ... /dstatus
    #               Other stuff about a grace period, even though in-product it says activated
    #               Last 5 characters of installed product key: <different>
    #       Automated install (product id = ProPlus2019Volume), activation by filling in PIDKEY
    #           THIS ATTEMPT WORKED
    #           Word > Account: Product Activated \ Microsoft Office Professional Plus 2019
    #           cscript "C:\Program Files\Microsoft Office\Office16\OSPP.VBS" /dstatus
    #               LICENSE NAME: Office 19, Office19ProPlus2019MSDNR_Retail edition
    #               LICENSE DESCRIPTION: Office 19, RETAIL channel
    #               LICENSE STATUS:  ---LICENSED---
    #               Last 5 characters of installed product key: <correct>
    #   Next attempts:
    #       1. Don't put PIDKEY in xml. Activate from command line.
    #           Example:    cscript "C:\Program Files\Microsoft Office\Office16\OSPP.VBS" /inpkey:XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
    #           Actual:     cscript "C:\Program Files\Microsoft Office\Office16\OSPP.VBS" /inpkey:(SecureRead-Host "Office key")
    #           Maybe also: cscript "C:\Program Files\Microsoft Office\Office16\OSPP.VBS" /act
    #           From: https://support.office.com/en-us/article/Change-your-Office-product-key-d78cf8f7-239e-4649-b726-3a8d2ceb8c81#ID0EABAAA=Command_line
    #           From: https://docs.microsoft.com/en-us/deployoffice/vlactivation/tools-to-manage-volume-activation-of-office#ospp
    #       2. SecureRead-Host to get Office key; write to copy of xml in tmp; use tmp configuration
    #       3. Manual activation
} {
    Test-ProgramInstalled "Microsoft Office Professional Plus 2019 - en-us"
}

InstallFromScoopBlock Sysinternals sysinternals

InstallFromGitHubBlock benallred Bahk { . $git\Bahk\Ben.ahk }

InstallFromGitHubBlock benallred SnapX { . $git\SnapX\SnapX.ahk }

InstallFromGitHubBlock benallred YouTubeToPlex

InstallFromGitHubBlock benallred mob

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

InstallFromMicrosoftStoreBlock "Microsoft To Do" 9nblggh5r558 Microsoft.Todos

InstallFromMicrosoftStoreBlock "Surface Audio" 9nxjnfwnvm8d Microsoft.SurfaceAudio

InstallFromMicrosoftStoreBlock "Dynamic Theme" 9nblggh1zbkw 55888ChristopheLavalle.DynamicTheme

InstallFromScoopBlock "Logitech Gaming Software" logitech-gaming-software-np

InstallFromScoopBlock Paint.NET paint.net

InstallFromScoopBlock "TreeSize Free" treesize-free

Block "Install Zoom" {
    if ((& $configure $forWork) -or (& $configure $forTest)) {
        iwr https://zoom.us/client/latest/ZoomInstaller.exe -OutFile "$env:tmp\ZoomInstaller.exe"
        . "$env:tmp\ZoomInstaller.exe"
        DeleteDesktopShortcut Zoom

        # Configure during install:
        #   https://support.zoom.us/hc/en-us/articles/201362163-Mass-Installation-and-Configuration-for-Windows#h_b82f0349-4d8f-45dd-898a-1ab98389a4b7
        #   Code
        #       iwr https://zoom.us/client/latest/ZoomInstallerFull.msi -OutFile "$env:tmp\ZoomInstallerFull.msi"
        #       msiexec /package "$env:tmp\ZoomInstallerFull.msi" ZRecommend="AutoHideToolbar=1"
        #   I can't get ZRecommend or ZConfig to work (settings are not changed)
        # Group policy:
        #   https://support.zoom.us/hc/en-us/articles/360039100051-Group-Policy-Options-for-the-Windows-Desktop-Client-and-Zoom-Rooms#h_e5b756c6-5e06-4a22-ad78-f19922a6e94f
        #   This works but the downside is the options are uneditable from the UI
        Set-RegistryValue "HKLM:\SOFTWARE\Policies\Zoom\Zoom Meetings\General" -Name AlwaysShowMeetingControls -Value 1
        Set-RegistryValue "HKLM:\SOFTWARE\Policies\Zoom\Zoom Meetings\General" -Name EnableRemindMeetingTime -Value 1
        Set-RegistryValue "HKLM:\SOFTWARE\Policies\Zoom\Zoom Meetings\General" -Name MuteWhenLockScreen -Value 1
        Set-RegistryValue "HKLM:\SOFTWARE\Policies\Zoom\Zoom Meetings\General" -Name TurnOffVideoCameraOnJoin -Value 1
        Set-RegistryValue "HKLM:\SOFTWARE\Policies\Zoom\Zoom Meetings\General" -Name AlwaysShowVideoPreviewDialog -Value 0
        Set-RegistryValue "HKLM:\SOFTWARE\Policies\Zoom\Zoom Meetings\General" -Name SetUseSystemDefaultMicForVOIP -Value 1
        Set-RegistryValue "HKLM:\SOFTWARE\Policies\Zoom\Zoom Meetings\General" -Name SetUseSystemDefaultSpeakerForVOIP -Value 1
        Set-RegistryValue "HKLM:\SOFTWARE\Policies\Zoom\Zoom Meetings\General" -Name AutoJoinVoIP -Value 1
        Set-RegistryValue "HKLM:\SOFTWARE\Policies\Zoom\Zoom Meetings\General" -Name MuteVoIPWhenJoinMeeting -Value 1
        Set-RegistryValue "HKLM:\SOFTWARE\Policies\Zoom\Zoom Meetings\General" -Name EnterFullScreenWhenViewingSharedScreen -Value 0
    }
} {
    Test-ProgramInstalled Zoom
}

InstallFromScoopBlock "Speedtest CLI" speedtest-cli
