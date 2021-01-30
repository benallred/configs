function InstallFollowup([string]$ProgramName, [scriptblock]$Followup) {
    ConfigFollowup "Finish $ProgramName Install" $Followup
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

if (!(Configured $forKids)) {
    Block "Install Edge (Dev)" {
        iwr "https://go.microsoft.com/fwlink/?linkid=2069324&Channel=Dev&language=en&Consent=1" -OutFile $env:tmp\MicrosoftEdgeSetupDev.exe
        . $env:tmp\MicrosoftEdgeSetupDev.exe
        DeleteDesktopShortcut "Microsoft Edge Dev"
    } {
        Test-ProgramInstalled "Microsoft Edge Dev"
    }
}

if (!(Configured $forKids)) {
    Block "Install Authy" {
        iwr "https://electron.authy.com/download?channel=stable&arch=x64&platform=win32&version=latest&product=authy" -OutFile "$env:tmp\Authy Desktop Setup.exe"
        . "$env:tmp\Authy Desktop Setup.exe"
        DeleteDesktopShortcut "Authy Desktop"
    } {
        Test-ProgramInstalled "Authy Desktop"
    }
}

InstallFromScoopBlock Everything everything {
    Copy-Item $PSScriptRoot\..\programs\Everything.ini (scoop prefix everything)
    everything -install-run-on-system-startup
    everything -startup
}

if (!(Configured $forKids)) {
    InstallFromScoopBlock .NET dotnet-sdk

    InstallFromScoopBlock nvm nvm {
        nvm install latest
        nvm use (nvm list)
    }

    InstallFromScoopBlock Yarn yarn
}

Block "Install VS Code" {
    iwr https://aka.ms/win32-x64-user-stable -OutFile $env:tmp\VSCodeUserSetup-x64.exe
    . $env:tmp\VSCodeUserSetup-x64.exe /SILENT /TASKS="associatewithfiles,addtopath" /LOG=$env:tmp\VSCodeInstallLog.txt
    WaitWhile { !(Test-ProgramInstalled "Visual Studio Code") } "Waiting for VS Code to be installed"
    $codeCmd = "$env:LocalAppData\Programs\Microsoft VS Code\bin\code.cmd"
    Write-ManualStep "Turn on Settings Sync"
    Write-ManualStep "`tReplace Local"
    Write-ManualStep "Watch log with ctrl+shift+u"
    Write-ManualStep "Show synced data"
    Write-ManualStep "`tUpdate name of synced machine"
    . $codeCmd
} {
    Test-ProgramInstalled "Microsoft Visual Studio Code (User)"
}

if (!(Configured $forKids)) {
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
            WaitWhile { !(Get-ChildItem "HKCU:\Software\Microsoft\VisualStudio" | ? { $_.PSChildName -match "^\d\d.\d_" }) } "Waiting for Visual Studio registry key"
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
        # External source navigation
        #   Perhaps edit $env:AppData\JetBrains\Shared\vAny\GlobalSettingsStorage.DotSettings
        #       Remove? <s:String x:Key="/Default/Housekeeping/OptionsDialog/SelectedPageId/@EntryValue">ExternalSources</s:String>
        #       Edit? <s:Int64 x:Key="/Default/Environment/SearchAndNavigation/DefaultOccurrencesGroupingIndices/=JetBrains_002EReSharper_002EFeature_002EServices_002ENavigation_002EDescriptors_002ESearchUsagesDescriptor/@EntryIndexedValue">12</s:Int64>
        #             <s:Int64 x:Key="/Default/Environment/SearchAndNavigation/DefaultOccurrencesGroupingIndices/=JetBrains_002EReSharper_002EFeature_002EServices_002ENavigation_002EDescriptors_002ESearchUsagesDescriptor/@EntryIndexedValue">12</s:Int64>
        #       Neither of the above seem to change when selecting an option in the popup
    } {
        Test-ProgramInstalled "JetBrains ReSharper in Visual Studio Professional 2019"
    }

    if (!(Configured $forTest)) {
        Block "Install Docker" {
            # https://github.com/docker/docker.github.io/issues/6910#issuecomment-403502065
            iwr https://download.docker.com/win/stable/Docker%20for%20Windows%20Installer.exe -OutFile "$env:tmp\Docker for Windows Installer.exe"
            # https://github.com/docker/for-win/issues/1322
            . "$env:tmp\Docker for Windows Installer.exe" install --quiet | Out-Default
            DeleteDesktopShortcut "Docker Desktop"
            ConfigureNotifications "Docker Desktop"
        } {
            Test-ProgramInstalled "Docker Desktop"
        } -RequiresReboot
    }
}

Block "Install AutoHotkey" {
    iwr https://www.autohotkey.com/download/ahk-install.exe -OutFile $env:tmp\ahk-install.exe
    . $env:tmp\ahk-install.exe /S /IsHostApp
} {
    Test-ProgramInstalled AutoHotkey
}

if (!(Configured $forKids)) {
    Block "Install Slack" {
        iwr https://downloads.slack-edge.com/releases_x64/SlackSetup.exe -OutFile $env:tmp\SlackSetup.exe
        . $env:tmp\SlackSetup.exe
        if (!(Configured $forWork)) {
            WaitWhile { !(Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name com.squirrel.slack.slack -ErrorAction Ignore) } "Waiting for Slack registry key"
            Remove-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name com.squirrel.slack.slack
        }
        DeleteDesktopShortcut Slack
        ConfigureNotifications Slack
    } {
        Test-ProgramInstalled Slack
    }
}

Block "Install Office" {
    # https://www.microsoft.com/en-in/download/details.aspx?id=49117
    $downloadUrl = (iwr "https://www.microsoft.com/en-in/download/confirmation.aspx?id=49117" -useb | sls "https://download\.microsoft\.com/download/.+?/officedeploymenttool_.+?.exe").Matches.Value
    iwr $downloadUrl -OutFile $env:tmp\officedeploymenttool.exe
    . $env:tmp\officedeploymenttool.exe /extract:$env:tmp\officedeploymenttool /passive /quiet
    WaitWhile { !(Test-Path $env:tmp\officedeploymenttool\setup.exe) } "Waiting for Office setup to be extracted"
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

InstallFromGitHubBlock benallred SnapX { . $git\SnapX\SnapX.ahk }

if (!(Configured $forKids)) {
    InstallFromGitHubBlock benallred Bahk { . $git\Bahk\Ben.ahk }

    InstallFromGitHubBlock benallred YouTubeToPlex

    InstallFromGitHubBlock benallred DilbertImageDownloader

    InstallFromGitHubBlock benallred mob {
        if (!(Test-Path $profile) -or !(Select-String "mob\.ps1" $profile)) {
            Add-Content -Path $profile -Value "`n"
            Add-Content -Path $profile -Value ". $git\mob\mob.ps1"
        }
    }
}

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

if (!(Configured $forKids) -and ((Configured $forWork) -or (Configured $forTest))) {
    Block "Install Firefox" {
        iwr "https://download.mozilla.org/?product=firefox-stub&os=win&lang=en-US" -OutFile "$env:tmp\Firefox Installer.exe"
        . "$env:tmp\Firefox Installer.exe"
        DeleteDesktopShortcut Firefox
    } {
        Test-ProgramInstalled "Mozilla Firefox"
    }
}

FirstRunBlock "Configure 7-Zip" {
    Set-RegistryValue "HKCU:\SOFTWARE\7-Zip\FM" -Name ShowDots -Value 1
    Set-RegistryValue "HKCU:\SOFTWARE\7-Zip\FM" -Name ShowRealFileIcons -Value 1
    Set-RegistryValue "HKCU:\SOFTWARE\7-Zip\FM" -Name FullRow -Value 1
    Set-RegistryValue "HKCU:\SOFTWARE\7-Zip\FM" -Name ShowSystemMenu -Value 1
    . "$(scoop prefix 7zip)\7zFM.exe"
    Write-ManualStep "Tools >"
    Write-ManualStep "`tOptions >"
    Write-ManualStep "`t`t7-Zip >"
    Write-ManualStep "`t`t`tContext menu items > [only the following]"
    Write-ManualStep "`t`t`t`tOpen archive"
    Write-ManualStep "`t`t`t`tExtract Here"
    Write-ManualStep "`t`t`t`tExtract to <Folder>"
    Write-ManualStep "`t`t`t`tAdd to <Archive>.zip"
    Write-ManualStep "`t`t`t`tCRC SHA >"
    WaitWhile { Get-Process 7zFM -ErrorAction Ignore } "Waiting for 7zFM to close"
}

InstallFromMicrosoftStoreBlock "Dynamic Theme" 9nblggh1zbkw 55888ChristopheLavalle.DynamicTheme

if (!(Configured $forKids)) {
    InstallFromMicrosoftStoreBlock "Microsoft To Do" 9nblggh5r558 Microsoft.Todos

    InstallFromMicrosoftStoreBlock "Todoist: To-Do List and Task Manager" 9nblggh1rl1k 88449BC3.TodoistTo-DoListTaskManager

    InstallFromMicrosoftStoreBlock "Surface Audio" 9nxjnfwnvm8d Microsoft.SurfaceAudio

    Block "Install Wally" {
        iwr https://configure.ergodox-ez.com/wally/win -OutFile $env:tmp\Wally.exe
        . $env:tmp\Wally.exe /SILENT /NORESTART /LOG=$env:tmp\WallyInstallLog.txt
    } {
        Test-ProgramInstalled Wally
    }

    InstallFromScoopBlock "Logitech Gaming Software" logitech-gaming-software-np

    InstallFromScoopBlock scrcpy scrcpy

    InstallFromScoopBlock "Speedtest CLI" speedtest-cli
}

InstallFromScoopBlock Paint.NET paint.net

InstallFromScoopBlock "TreeSize Free" treesize-free
