function InstallFollowup([string]$ProgramName, [scriptblock]$Followup) {
    ConfigFollowup "Finish $ProgramName Install" $Followup
}

function RemoveStartupRegistryKey([string]$ValueName) {
    WaitWhile { !(Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name $ValueName -ErrorAction Ignore) } "Waiting for `"$ValueName`" startup registry key"
    Remove-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name $ValueName
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
        Download-File "https://go.microsoft.com/fwlink/?linkid=2069324&Channel=Dev&language=en&Consent=1" $env:tmp\MicrosoftEdgeSetupDev.exe
        . $env:tmp\MicrosoftEdgeSetupDev.exe
        DeleteDesktopShortcut "Microsoft Edge Dev"
    } {
        Test-ProgramInstalled "Microsoft Edge Dev"
    }
}

if (!(Configured $forKids)) {
    Block "Install Authy" {
        Download-File "https://electron.authy.com/download?channel=stable&arch=x64&platform=win32&version=latest&product=authy" "$env:tmp\Authy Desktop Setup.exe"
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
    InstallFromScoopBlock .NET dotnet-sdk {
        Add-Content -Path $profile {
            Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
                param($wordToComplete, $commandAst, $cursorPosition)
                dotnet complete --position $cursorPosition $commandAst | ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
                }
            }
        }
    }

    InstallFromScoopBlock nvm nvm {
        nvm install latest
        nvm use (nvm list)
    }

    InstallFromScoopBlock Yarn yarn

    InstallFromScoopBlock "GitHub CLI" gh {
        gh config set editor (git config core.editor)
        if (!(Configured $forTest)) {
            gh auth login -w
        }
    }
}

Block "Install VS Code" {
    Download-File https://aka.ms/win32-x64-user-stable $env:tmp\VSCodeUserSetup-x64.exe
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
        $downloadUrl = (iwr "https://visualstudio.microsoft.com/thank-you-downloading-visual-studio/?sku=Professional&rel=16" | sls "https://download\.visualstudio\.microsoft\.com/download/pr/.+?/vs_Professional.exe").Matches.Value
        Download-File $downloadUrl $env:tmp\vs_professional.exe
        # https://docs.microsoft.com/en-us/visualstudio/install/workload-and-component-ids?view=vs-2019
        # Microsoft.VisualStudio.Workload.ManagedDesktop    .NET desktop development
        # Microsoft.VisualStudio.Workload.NetWeb            ASP.NET and web development
        # Microsoft.VisualStudio.Workload.NetCoreTools      .NET Core cross-platform development
        # https://docs.microsoft.com/en-us/visualstudio/install/command-line-parameter-examples?view=vs-2019#using---wait
        $vsInstallArgs = '--passive', '--norestart', '--wait', '--includeRecommended', '--add', 'Microsoft.VisualStudio.Workload.ManagedDesktop', '--add', 'Microsoft.VisualStudio.Workload.NetWeb', '--add', 'Microsoft.VisualStudio.Workload.NetCoreTools'
        Start-Process $env:tmp\vs_professional.exe $vsInstallArgs -Wait
        InstallFollowup "Visual Studio" {
            . (. "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -property productPath) $PSCommandPath
            WaitWhile { !(Get-ChildItem "HKCU:\Software\Microsoft\VisualStudio" | ? { $_.PSChildName -match "^\d\d.\d_" }) } "Waiting for Visual Studio registry key"
            & "$git\configs\programs\Visual Studio - Hide dynamic nodes in Solution Explorer.ps1"
        }

        function InstallVisualStudioExtension([string]$Publisher, [string]$Extension) {
            $downloadUrl = (iwr "https://marketplace.visualstudio.com/items?itemName=$Publisher.$Extension" | sls "/_apis/public/gallery/publishers/$Publisher/vsextensions/$Extension/(\d+\.?)+/vspackage").Matches.Value | % { "https://marketplace.visualstudio.com$_" }
            Download-File $downloadUrl $env:tmp\$Publisher.$Extension.vsix
            $vsixInstaller = . "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -all -property productPath | Split-Path | % { "$_\VSIXInstaller.exe" }
            $installArgs = "/quiet", "/admin", "$env:tmp\$Publisher.$Extension.vsix"
            Write-Output "Installing $Extension"
            Start-Process $vsixInstaller $installArgs -Wait
        }

        InstallVisualStudioExtension VisualStudioPlatformTeam SolutionErrorVisualizer
        InstallVisualStudioExtension VisualStudioPlatformTeam FixMixedTabs
        InstallVisualStudioExtension VisualStudioPlatformTeam PowerCommandsforVisualStudio
        InstallVisualStudioExtension maksim-vorobiev PeasyMotion
        InstallVisualStudioExtension JustinClareburtMSFT HotStatus
        InstallVisualStudioExtension MadsKristensen ResetZoom
    } {
        Test-ProgramInstalled "Visual Studio Professional 2019"
    }

    if (!(Configured $forTest)) {
        Block "Install Docker" {
            Download-File https://desktop.docker.com/win/stable/Docker%20Desktop%20Installer.exe "$env:tmp\Docker Desktop Installer.exe"
            # https://github.com/docker/for-win/issues/1322
            . "$env:tmp\Docker Desktop Installer.exe" install --quiet | Out-Default
            DeleteDesktopShortcut "Docker Desktop"
            ConfigureNotifications "Docker Desktop"
            RemoveStartupRegistryKey "Docker Desktop"
        } {
            Test-ProgramInstalled "Docker Desktop"
        } -RequiresReboot
    }
}

Block "Install AutoHotkey" {
    Download-File https://www.autohotkey.com/download/ahk-install.exe $env:tmp\ahk-install.exe
    . $env:tmp\ahk-install.exe /S /IsHostApp
} {
    Test-ProgramInstalled AutoHotkey
}

if (!(Configured $forKids)) {
    Block "Install Slack" {
        Download-File https://downloads.slack-edge.com/releases_x64/SlackSetup.exe $env:tmp\SlackSetup.exe
        . $env:tmp\SlackSetup.exe
        if (!(Configured $forWork)) {
            RemoveStartupRegistryKey com.squirrel.slack.slack
        }
        DeleteDesktopShortcut Slack
        ConfigureNotifications Slack
    } {
        Test-ProgramInstalled Slack
    }
}

Block "Install Office" {
    # https://www.microsoft.com/en-in/download/details.aspx?id=49117
    $downloadUrl = (iwr "https://www.microsoft.com/en-in/download/confirmation.aspx?id=49117" | sls "https://download\.microsoft\.com/download/.+?/officedeploymenttool_.+?.exe").Matches.Value
    Download-File $downloadUrl $env:tmp\officedeploymenttool.exe
    . $env:tmp\officedeploymenttool.exe /extract:$env:tmp\officedeploymenttool /passive /quiet
    WaitForPath $env:tmp\officedeploymenttool\setup.exe
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
    (Test-ProgramInstalled "Microsoft Office") -or (Test-ProgramInstalled "Microsoft 365")
}

Block "Configure Office" {
    # Options > Mail > Compose messages > Editor Options > Proofing > AutoCorrect Options > AutoCorrect > Replace ... with ... = Delete
    # Options > Mail > Compose messages > Editor Options > Proofing > AutoCorrect Options > AutoCorrect > Replace hsa with has = Delete
    # Options > Mail > Compose messages > Editor Options > Proofing > AutoCorrect Options > AutoFormat As You Type > "Straight quotes" with "smart quotes" = Off
    # Options > Mail > Compose messages > Editor Options > Proofing > AutoCorrect Options > AutoFormat As You Type > Hyphens (--) with dash (--) = Off
    # Options > Mail > Compose messages > Editor Options > Proofing > AutoCorrect Options > AutoFormat > "Straight quotes" with "smart quotes" = Off
    # Options > Mail > Compose messages > Editor Options > Proofing > AutoCorrect Options > AutoFormat > Hyphens (--) with dash (--) = Off
    # Options > Mail > Compose messages > Editor Options > Advanced > Cut, copy, and paste > Use smart cut and paste > Settings > Adjust sentence and word spacing automatically = Off
    # Options > Mail > Outlook panes > Reading Pane > Mark items as read when viewed in the Reading Pane = Yes
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Preferences" -Name PreviewMarkMessage -Value 1
    # Options > Mail > Outlook panes > Reading Pane > Mark items as read when viewed in the Reading Pane = Yes > Wait seconds = 0
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Preferences" -Name PreviewWaitSeconds -Value 0
    # Options > Calendar > Display options > Automatically switch from vertical layout to schedule view ... = Off
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Options\WunderBar" -Name EnableAutoSwitchingVerticalToHorizontal -Value 0
    # Options > People > Online status and photographs > Show user photographs when available = Off
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Office\16.0\Common" -Name TurnOffPhotograph -Value 1
    # Options > Search > Results > Include messages from the Deleted Items folder in each data file when searching in All Items = Yes
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Search" -Name IncludeDeletedItems -Value 1
    # Options > Advanced > AutoArchive > AutoArchive Settings > Run AutoArchive every = 7 days
    # Options > Advanced > AutoArchive > AutoArchive Settings > Delete expired items (e-mail folders only) = Off
    # If home machine: Options > Advanced > AutoArchive > AutoArchive Settings > Archive or delete old items = Off
    # If work machine: Options > Advanced > AutoArchive > AutoArchive Settings > Clean out items older than: 2 months
    # If work machine: Options > Advanced > AutoArchive > AutoArchive Settings > Move old items to: <Current Year>.pst
    # Options > Advanced > Reminders > Show reminders = Off
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Options\Reminders" -Name Type -Value 0
    # Options > Advanced > Other > Allow analysis ... = Off
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Office\16.0\Common\Portal\ColleagueImport" -Name Enabled -Value 0
    # Options > Quick Access Toolbar > Choose commands from = All Commands
    # Options > Quick Access Toolbar > Choose commands from = All Commands > Add > Message Options...
    # Options > Add-ins > Manage COM Add-ins > Microsoft SharePoint Server Colleague Import Add-in = Off
    # Options > Add-ins > Manage COM Add-ins > OneNote Notes about Outlook Items = Off
    # Options > Add-ins > Manage COM Add-ins > Outlook Social Connector 2016 = Off
    # If home machine: Options > Add-ins > Manage COM Add-ins > Skype Meeting Add-in for Microsoft Office 2016 = Off
    # UI Changes > View > Layout > Folder Pane > Favorites = Off
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Preferences" -Name HideMailFavorites -Value 1
    # UI Changes > View > Layout > Use Tighter Spacing = Yes
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Preferences" -Name DensitySetting -Value 1
    # UI Changes > Open e-mail message > Remove items in Quick Access Toolbar
    # UI Changes > Open e-mail message > Add "Mark Unread" (not "Mark as Unread"; "Mark as Unread" does not toggle)
    # UI Changes > Open new e-mail > Remove items in Quick Access Toolbar
    # UI Changes > Open new e-mail > Add "Save Sent Item To"
}

InstallFromScoopBlock Sysinternals sysinternals

InstallFromGitHubBlock benallred SnapX { . $git\SnapX\SnapX.ahk }

if (!(Configured $forKids)) {
    InstallFromGitHubBlock benallred Bahk { . $git\Bahk\Ben.ahk }

    InstallFromGitHubBlock benallred YouTubeToPlex

    InstallFromGitHubBlock benallred DilbertImageDownloader

    InstallFromGitHubBlock benallred qmk_firmware {
        git submodule update --init --recursive
        git remote add upstream https://github.com/zsa/qmk_firmware.git
        git co ben
    }

    InstallFromGitHubAssetBlock qmk qmk_distro_msys QMK_MSYS.exe {
        Start-Process QMK_MSYS.exe "/silent" -Wait
        C:\QMK_MSYS\shell_connector.cmd -c "qmk config user.hide_welcome=True"
        C:\QMK_MSYS\shell_connector.cmd -c "qmk config user.qmk_home=$($git -replace "\\", "/")/qmk_firmware"
        C:\QMK_MSYS\shell_connector.cmd -c "qmk setup"
    } {
        Test-ProgramInstalled "QMK MSYS"
    }

    InstallFromGitHubBlock benallred mob {
        if (!(Test-Path $profile) -or !(Select-String "mob\.ps1" $profile)) {
            Add-Content -Path $profile -Value "`n"
            Add-Content -Path $profile -Value ". $git\mob\mob.ps1"
        }
    }
}

Block "Install Steam" {
    Download-File https://steamcdn-a.akamaihd.net/client/installer/SteamSetup.exe $env:tmp\SteamSetup.exe
    Start-Process $env:tmp\SteamSetup.exe "/S" -Wait
    DeleteDesktopShortcut Steam
    if (Configured $forWork) {
        RemoveStartupRegistryKey Steam
    }
} {
    Test-ProgramInstalled "Steam"
}

Block "Install Battle.net" {
    Download-File https://www.battle.net/download/getInstallerForGame $env:tmp\Battle.net-Setup.exe
    . $env:tmp\Battle.net-Setup.exe
    DeleteDesktopShortcut Battle.net
} {
    Test-ProgramInstalled "Battle.net"
}

if (!(Configured $forKids)) {
    if (!(Configured $forWork)) {
        Block "Install Epic Games" {
            Download-File https://launcher-public-service-prod06.ol.epicgames.com/launcher/api/installer/download/EpicGamesLauncherInstaller.msi $env:tmp\EpicGamesLauncherInstaller.msi
            Start-Process $env:tmp\EpicGamesLauncherInstaller.msi "/passive" -Wait
            DeleteDesktopShortcut "Epic Games Launcher"
            . "${env:ProgramFiles(x86)}\Epic Games\Launcher\Portal\Binaries\Win32\EpicGamesLauncher.exe"
            RemoveStartupRegistryKey EpicGamesLauncher
            $epicGamesSettingsFile = "$env:LocalAppData\EpicGamesLauncher\Saved\Config\Windows\GameUserSettings.ini"
            (Get-Content $epicGamesSettingsFile) -replace "\[Launcher\]", "`$0`nDefaultAppInstallLocation=D:\Installs\Epic Games" | Set-Content $epicGamesSettingsFile
            (Get-Content $epicGamesSettingsFile) -replace "\[.+?_General\]", "`$0`nNotificationsEnabled_Adverts=False" | Set-Content $epicGamesSettingsFile
        } {
            Test-ProgramInstalled "Epic Games Launcher"
        }
    }

    Block "Install Discord" {
        Download-File https://discord.com/api/download?platform=win $env:tmp\DiscordSetup.exe
        . $env:tmp\DiscordSetup.exe
        DeleteDesktopShortcut Discord
        WaitForPath $env:AppData\discord\settings.json
        $discordSettings = Get-Content $env:AppData\discord\settings.json | ConvertFrom-Json
        $discordSettings | Add-Member NoteProperty START_MINIMIZED $true
        ConvertTo-Json $discordSettings | Set-Content $env:AppData\discord\settings.json
    } {
        Test-ProgramInstalled Discord
    }
}

if (!(Configured $forKids) -and ((Configured $forWork) -or (Configured $forTest))) {
    Block "Install Firefox" {
        Download-File "https://download.mozilla.org/?product=firefox-stub&os=win&lang=en-US" "$env:tmp\Firefox Installer.exe"
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
    WaitWhileProcess 7zFM
}

InstallFromMicrosoftStoreBlock "Dynamic Theme" 9nblggh1zbkw 55888ChristopheLavalle.DynamicTheme

if (!(Configured $forKids)) {
    InstallFromMicrosoftStoreBlock "Microsoft To Do" 9nblggh5r558 Microsoft.Todos

    InstallFromMicrosoftStoreBlock "Surface Audio" 9nxjnfwnvm8d Microsoft.SurfaceAudio

    Block "Install Todoist" {
        Download-File "https://todoist.com/windows_app" "$env:tmp\Todoist.exe"
        . "$env:tmp\Todoist.exe"
        DeleteDesktopShortcut Todoist
    } {
        Test-ProgramInstalled Todoist
    }

    Block "Install Wally" {
        Download-File https://configure.ergodox-ez.com/wally/win $env:tmp\Wally.exe
        . $env:tmp\Wally.exe /SILENT /NORESTART /LOG=$env:tmp\WallyInstallLog.txt
    } {
        Test-ProgramInstalled Wally
    }

    InstallFromScoopBlock "Logitech Gaming Software" logitech-gaming-software-np

    InstallFromGitHubAssetBlock imbushuo mac-precision-touchpad Drivers-amd64-ReleaseMSSigned.zip {
        pnputil /add-driver .\drivers\amd64\AmtPtpDevice.inf /install
    } {
        pnputil /enum-drivers | sls AmtPtpDevice.inf
    }

    InstallFromScoopBlock scrcpy scrcpy

    InstallFromScoopBlock "Speedtest CLI" speedtest-cli
}

InstallFromScoopBlock Paint.NET paint.net

InstallFromScoopBlock "TreeSize Free" treesize-free

if (Configured $forKids) {
    Block "Install Scratch" {
        Download-File https://downloads.scratch.mit.edu/desktop/Scratch%20Setup.exe "$env:tmp\Scratch Setup.exe"
        . "$env:tmp\Scratch Setup.exe"
        DeleteDesktopShortcut "Scratch Desktop"
    } {
        Test-ProgramInstalled "Scratch Desktop"
    }
}

Block "Install Cricut Design Space" {
    $fileName = (iwr https://s3-us-west-2.amazonaws.com/staticcontent.cricut.com/a/software/win32-native/latest.json | ConvertFrom-Json).rolloutInstallFile
    Download-File https://staticcontent.cricut.com/a/software/win32-native/$fileName $env:tmp\$fileName
    . $env:tmp\$fileName
    DeleteDesktopShortcut "Cricut Design Space"
} {
    Test-ProgramInstalled "Cricut Design Space"
}
