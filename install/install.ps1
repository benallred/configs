InstallFromWingetBlock Git.Git

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

if (Configured $forHome, $forWork, $forTest) {
    InstallFromWingetBlock Microsoft.Edge.Dev {
        DeleteDesktopShortcut "Microsoft Edge Dev"
        Write-ManualStep "Navigate to"
        Write-ManualStep "edge://settings/appearance"
        Write-ManualStep "`tCustomize toolbar > Hide title bar while in vertical tabs = On"
        Write-ManualStep "Navigate to"
        Write-ManualStep "edge://extensions/shortcuts"
        Write-ManualStep "`tBitwarden"
        Write-ManualStep "`t`tActivate the extension = Ctrl + Shift + B"
        Write-ManualStep "`t`tAuto-fill the last used login for the current website = Alt + Page down"
        Write-ManualStep "`t`tGenerate and copy a new random password to the clipboard = Ctrl + Shift + G"
        Write-ManualStep "`tDark Reader"
        Write-ManualStep "`t`tToggle current site = Alt + J"
        Write-ManualStep "`t`tToggle extension = Alt + Shift + J"
        Write-ManualStep "`tLink to Text Fragment > Copy Link to Selected Text = Alt + C"
        if (Configured $forWork) {
            Write-ManualStep "BitWarden > Settings > Vault timeout = 5 minutes"

            ConfigureNotifications Microsoft.MicrosoftEdge.Dev_8wekyb3d8bbwe!https://calendar.google.com/ AllowUrgentNotifications $true
        }
    }

    InstallFromWingetBlock Twilio.Authy {
        DeleteDesktopShortcut "Authy Desktop"
    }

    InstallFromWingetBlock Microsoft.DotNet.SDK.6 {
        Add-Content -Path $profile {
            Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
                param($wordToComplete, $commandAst, $cursorPosition)
                dotnet complete --position $cursorPosition $commandAst | ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
                }
            }
        }
    }

    Block "Add nuget.org source" {
        dotnet nuget add source https://api.nuget.org/v3/index.json -n nuget.org
    } {
        dotnet nuget list source | sls nuget.org
    }

    InstallFromWingetBlock Yarn.Yarn

    InstallFromWingetBlock GitHub.cli {
        gh config set editor (git config core.editor)
        Add-Content -Path $profile {
            (gh completion -s powershell) -join "`n" | iex
        }
        if (!(Configured $forTest)) {
            $ghPat_Cli = SecureRead-Host "GH PAT (CLI)"
            $ghPat_Cli | gh auth login --with-token
        }
    }
}

InstallFromWingetBlock voidtools.Everything {
    DeleteDesktopShortcut Everything
    Copy-Item $PSScriptRoot\..\programs\Everything.ini $env:ProgramFiles\Everything\
    . $env:ProgramFiles\Everything\Everything.exe -install-run-on-system-startup
    . $env:ProgramFiles\Everything\Everything.exe -startup
}

InstallFromWingetBlock Microsoft.VisualStudioCode {
    Write-ManualStep "Turn on Settings Sync"
    Write-ManualStep "`tReplace Local"
    Write-ManualStep "Watch log with ctrl+shift+u"
    Write-ManualStep "Show synced data"
    Write-ManualStep "`tUpdate name of synced machine"
    code
}

InstallFromWingetBlock Lexikos.AutoHotkey "/S /IsHostApp"

if (Configured $forHome, $forWork, $forTest) {
    InstallFromWingetBlock Microsoft.VisualStudio.2022.Community `
        "--passive --norestart --wait --includeRecommended --add Microsoft.VisualStudio.Workload.ManagedDesktop --add Microsoft.VisualStudio.Workload.NetWeb" `
    {
        # https://docs.microsoft.com/en-us/visualstudio/install/workload-and-component-ids
        #   Microsoft.VisualStudio.Workload.ManagedDesktop    .NET desktop development
        #   Microsoft.VisualStudio.Workload.NetWeb            ASP.NET and web development
        # https://docs.microsoft.com/en-us/visualstudio/install/command-line-parameter-examples#using---wait

        $vsInstallation = . "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -format json | ConvertFrom-Json
        $vsVersion = ($vsInstallation.installationVersion).Substring(0, 2)

        # Hide dynamic nodes in Solution Explorer
        Set-RegistryValue "HKCU:\Software\Microsoft\VisualStudio\$vsVersion.0_$($vsInstallation.instanceId)" -Name UseSolutionNavigatorGraphProvider -Value 0

        # Visual Studio > Help > Privacy > Privacy Settings... > Experience Improvement Program = No
        Set-RegistryValue "HKLM:\SOFTWARE\WOW6432Node\Microsoft\VSCommon\$vsVersion.0\SQM" -Name OptIn -Value 0
    } -NoUpdate

    InstallVisualStudioExtensionBlock maksim-vorobiev PeasyMotion2022
    InstallVisualStudioExtensionBlock OlleWestman SubwordNavigation
    InstallVisualStudioExtensionBlock AlexanderGayko ShowInlineErrors
    InstallVisualStudioExtensionBlock MadsKristensen ResetZoom

    InstallFromWingetBlock SlackTechnologies.Slack {
        if (!(Configured $forWork)) {
            RemoveStartupRegistryKey com.squirrel.slack.slack
        }
        DeleteDesktopShortcut Slack
        ConfigureNotifications com.squirrel.slack.slack ShowInActionCenter $false
    }
}

if ((Test-ProgramInstalled "Microsoft 365 - en-us") -and ((Read-Host "Use key to activate Office? (y/n)") -eq "y")) {
    winget uninstall "Microsoft 365 - en-us"
}

if (!(Configured $forHtpc)) {
    if (!((Test-ProgramInstalled "Microsoft Office Professional Plus 2019") -or (Test-ProgramInstalled "Microsoft Office 365") -or (Test-ProgramInstalled "Microsoft 365"))) {
        InstallFromWingetBlock Microsoft.Office "/configure $PSScriptRoot\OfficeConfiguration.xml" {
            if (Configured $forHome) {
                Activate-Office
            }
        }
    }
}

Block "Configure Office" {
    ##########
    ## Outlook
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
    # Options > Mail > Outlook panes > Reading Pane > Mark item as read when selection changes = No
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Preferences" -Name PreviewDontMarkUntilChange -Value 0
    # Options > Mail > Message arrival > Show an envelope icon in the taskbar = No
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Preferences" -Name ShowEnvelope -Value 0
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Office\Outlook\Settings\Data" -Name global_Mail_ShowEnvelope -Value '{"value":"false"}'
    # Options > Mail > Send messages > CTRL + ENTER sends a message = On
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Preferences" -Name CtrlEnterSends -Value 1
    # Options > Mail > Tracking > For any message received that includes a read receipt request = Never send a read receipt
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Options\Mail" -Name "Receipt Response" -Value 1
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
    # Options > Advanced > Outlook panes > Show Apps in Outlook = No
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Preferences" -Name EnableAppsInOutlook -Value 0
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

    ConfigureNotifications Microsoft.Office.OUTLOOK.EXE.15 ShowInActionCenter $false

    function UpdatePontString([int]$id) {
        $pontString = (Get-ItemProperty "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Options\General" -ErrorAction Ignore).PONT_STRING
        if ($pontString -notmatch "$id,") {
            Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Office\16.0\Outlook\Options\General" -Name PONT_STRING -Value "$pontString$id,"
        }
    }
    # Reply (Automatic Picture Download) > Don't show this message again = On
    UpdatePontString 32
    # Junk > Block Sender > Don't show this message again = On
    UpdatePontString 35
    # Add Sender to Safe Senders List > Don't show this message again = On
    UpdatePontString 36
    # No Response Required (This meeting request will now be deleted) > Don't show this message again = On
    UpdatePontString 44

    ##########
    ## OneNote
    # Options > Display > Place OneNote icon in the notification area of the taskbar = Off
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Office\16.0\OneNote\Options\Other" -Name RunSystemTrayApp -Value 0
    # Options > Display > Page tabs appear on the left = On
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Office\16.0\OneNote\Options\Other" -Name PageTabsOnLeft -Value 1
    # Options > Display > Navigation bar appears on the left = On
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Office\16.0\OneNote\Options\Other" -Name NavBarOnLeft -Value 1
    # Options > Proofing > AutoCorrect Options... > AutoCorrect > Capitalize first letter of sentences = Off
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Office\16.0\Common\AutoCorrect" -Name CapitalizeSentence -Value 0
    # Options > Proofing > Hide spelling and grammar errors = On
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Shared Tools\Proofing Tools\1.0\Office" -Name OneNoteSpellingOptions -Value 7
    # Options > Advanced > Editing > Include link to source when pasting from the Web = Off
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Office\16.0\OneNote\Options\Editing" -Name PasteIncludeURL -Value 0
    # UI Changes > Pin Notebook Pane to Side
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Office\16.0\OneNote\Options\Other" -Name NavigationBarExpColState -Value 0
}

InstallFromScoopBlock sysinternals {
    Set-RegistryValue "HKCU:\Software\Sysinternals" EulaAccepted 1
}

InstallFromGitHubBlock benallred SnapX
Block "Start SnapX" {
    . $git\SnapX\SnapX.ahk
} {
    (Get-Process AutoHotkey -ErrorAction Ignore).CommandLine | sls SnapX.ahk
}

if (Configured $forHome, $forWork, $forTest) {
    InstallFromGitHubBlock benallred Bahk
    Block "Start Bahk" {
        . $git\Bahk\Ben.ahk
    } {
        (Get-Process AutoHotkey -ErrorAction Ignore).CommandLine | sls Ben.ahk
    }

    if (Configured $forHome) {
        Block "Install CrashPlan" {
            Download-File https://download.code42.com/installs/agent/latest-smb-win64.msi $env:tmp\CrashPlan.msi
            Start-Process $env:tmp\CrashPlan.msi /passive, /norestart -Wait
            Write-ManualStep "Sign in"
            Write-ManualStep "Replace Existing"
            Write-ManualStep "Skip File Transfer"
        } {
            Test-ProgramInstalled Code42
        }
    }

    InstallFromGitHubBlock benallred plex-playlist-liberator

    InstallFromGitHubBlock benallred YouTubeToPlex

    InstallFromGitHubBlock benallred DilbertImageDownloader

    InstallFromGitHubBlock benallred what-i-use

    InstallFromGitHubBlock benallred presentations

    InstallFromGitHubBlock benallred qmk_firmware {
        git pull --unshallow
        git config remote.origin.fetch +refs/heads/*:refs/remotes/origin/*
        git submodule update --init --recursive
        git remote add upstream https://github.com/zsa/qmk_firmware.git
        git co ben
    } -CloneDepth 1

    InstallFromGitHubAssetBlock qmk qmk_distro_msys QMK_MSYS.exe {
        Start-Process QMK_MSYS.exe "/silent" -Wait
        C:\QMK_MSYS\shell_connector.cmd -c "qmk config user.hide_welcome=True"
        C:\QMK_MSYS\shell_connector.cmd -c "qmk config user.qmk_home=$($git -replace "\\", "/")/qmk_firmware"
        C:\QMK_MSYS\shell_connector.cmd -c "qmk setup"
    } {
        Test-ProgramInstalled "QMK MSYS"
    }

    InstallFromWingetBlock Discord.Discord {
        DeleteDesktopShortcut Discord
        ConfigureNotifications com.squirrel.Discord.Discord ShowInActionCenter $false
        WaitForPath "$env:AppData\Microsoft\Windows\Start Menu\Programs\Discord Inc\Discord.lnk"
        . "$env:AppData\Microsoft\Windows\Start Menu\Programs\Discord Inc\Discord.lnk"
        WaitForPath $env:AppData\discord\settings.json
        $discordSettings = Get-Content $env:AppData\discord\settings.json | ConvertFrom-Json
        $discordSettings | Add-Member NoteProperty START_MINIMIZED $true
        ConvertTo-Json $discordSettings | Set-Content $env:AppData\discord\settings.json
    } -NoUpdate
}

InstallFromWingetBlock 7zip.7zip {
    Set-RegistryValue "HKCU:\SOFTWARE\7-Zip\FM" -Name ShowDots -Value 1
    Set-RegistryValue "HKCU:\SOFTWARE\7-Zip\FM" -Name ShowRealFileIcons -Value 1
    Set-RegistryValue "HKCU:\SOFTWARE\7-Zip\FM" -Name FullRow -Value 1
    Set-RegistryValue "HKCU:\SOFTWARE\7-Zip\FM" -Name ShowSystemMenu -Value 1
    . "$env:ProgramFiles\7-Zip\7zFM.exe"
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

if (Configured $forHome) {
    FirstRunBlock "Wait for Plex backup restore" {
        WaitForPath "HKCU:\SOFTWARE\PlexPlaylistLiberator"
    }
    InstallFromWingetBlock Plex.PlexMediaServer
}

if (!(Configured $forHtpc)) {
    InstallFromWingetBlock Plex.Plexamp {
        DeleteDesktopShortcut Plexamp
        ConfigureNotifications tv.plex.plexamp ShowInActionCenter $false
        Copy-Item2 $PSScriptRoot\..\programs\Plexamp.MainWindow.json $env:AppData\Plexamp\MainWindow.json
        Write-ManualStep "Sign in to Plexamp"
        . $env:LocalAppData\Programs\Plexamp\Plexamp.exe
    } -NoUpdate
}

InstallFromWingetBlock 9NBLGGH1ZBKW # Dynamic Theme

if (Configured $forHome, $forWork, $forTest) {
    InstallFromWingetBlock 9NBLGGH5R558 # Microsoft To Do

    InstallFromWingetBlock 9WZDNCRFJB8P # Surface

    InstallFromWingetBlock Doist.Todoist {
        DeleteDesktopShortcut Todoist
    }

    Block "Install Keymapp" {
        Download-File https://oryx.nyc3.cdn.digitaloceanspaces.com/keymapp/keymapp-latest.exe $env:tmp\keymapp-latest.exe
        . $env:tmp\keymapp-latest.exe /SILENT /NORESTART /LOG=$env:tmp\KeymappInstallLog.txt
    } {
        Test-ProgramInstalled Keymapp
    }

    InstallFromWingetBlock Logitech.LGS

    InstallFromWingetBlock Logitech.Options

    InstallFromGitHubAssetBlock imbushuo mac-precision-touchpad Drivers-amd64-ReleaseMSSigned.zip {
        pnputil /add-driver .\drivers\amd64\AmtPtpDevice.inf /install
    } {
        pnputil /enum-drivers | sls AmtPtpDevice.inf
    }

    InstallFromWingetBlock SergeySerkov.TagScanner {
        DeleteDesktopShortcut TagScanner
        New-Item $env:AppData\TagScanner -ItemType Directory
        Copy-Item $PSScriptRoot\..\programs\Tagscan.ini $env:AppData\TagScanner
    }

    InstallFromWingetBlock yt-dlp.yt-dlp

    Block "Install Python" {
        $latestPython = winget search Python | sls "Python\.Python\.\d+\.(\d+)" | % { @{ id = $_.Matches.Value; sort = [int]$_.Matches.Groups[1].Value } } | sort sort -Descending | select -First 1 -ExpandProperty id
        InstallFromWingetBlock $latestPython
    }

    Block "Install mutagen" {
        pip install mutagen
    }

    InstallFromWingetBlock Genymobile.scrcpy

    InstallFromWingetBlock Ookla.Speedtest.CLI {
        speedtest --accept-license --version
    }

    InstallFromWingetBlock Rufus.Rufus {
        New-Shortcut (Get-ChildItem "$env:LocalAppData\Microsoft\WinGet\Packages\Rufus.Rufus_Microsoft.Winget.Source_8wekyb3d8bbwe" rufus*.exe) "$env:AppData\Microsoft\Windows\Start Menu\Programs\Ben\Rufus.lnk"
    }

    Block "Install RegFromApp" {
        Download-File https://www.nirsoft.net/utils/regfromapp-x64.zip $env:tmp\regfromapp-x64.zip
        Expand-Archive $env:tmp\regfromapp-x64.zip C:\BenLocal\Programs\RegFromApp64
        New-Shortcut C:\BenLocal\Programs\RegFromApp64\RegFromApp.exe "$env:AppData\Microsoft\Windows\Start Menu\Programs\Ben\RegFromApp64.lnk"
        Download-File https://www.nirsoft.net/utils/regfromapp.zip $env:tmp\regfromapp.zip
        Expand-Archive $env:tmp\regfromapp.zip C:\BenLocal\Programs\RegFromApp
        New-Shortcut C:\BenLocal\Programs\RegFromApp\RegFromApp.exe "$env:AppData\Microsoft\Windows\Start Menu\Programs\Ben\RegFromApp.lnk"
    } {
        Test-Path C:\BenLocal\Programs\RegFromApp64
    }

    if (Configured $forHome) {
        Block "Install OverDrive" {
            Download-File https://static.od-cdn.com/ODMediaConsoleSetup.msi $env:tmp\ODMediaConsoleSetup.msi
            Start-Process $env:tmp\ODMediaConsoleSetup.msi /passive, /norestart -Wait
            DeleteDesktopShortcut "OverDrive for Windows"
            Set-RegistryValue "HKCU:\Software\OverDrive, Inc.\OverDrive Media Console\Settings" "DownloadFolder-MP3 Audiobook" "C:\BenLocal\Audio Books"
        } {
            Test-ProgramInstalled "OverDrive for Windows"
        }
    }

    InstallFromWingetBlock NickeManarin.ScreenToGif {
        DeleteDesktopShortcut ScreenToGif
        Copy-Item2 $PSScriptRoot\..\programs\ScreenToGif.xaml $env:AppData\ScreenToGif\Settings.xaml
    }

    Block "Update VeraCrypt" {
        $currentDir = "$script:veraCryptRootDir\Current"
        $newVersionDir = "$script:veraCryptRootDir\$script:veraCryptNewVersion"
        $downloadPath = "$script:veraCryptRootDir\VeraCrypt Portable $script:veraCryptNewVersion.exe"

        rm $script:veraCryptRootDir\$script:veraCryptOldVersion
        Rename-Item $currentDir $script:veraCryptOldVersion

        Download-File https://launchpad.net/veracrypt/trunk/$script:veraCryptNewVersion/+download/VeraCrypt%20Portable%20$script:veraCryptNewVersion.exe $downloadPath
        mkdir $newVersionDir | Out-Null
        $currentDir | Set-Clipboard
        Write-ManualStep "Extract to `"$currentDir`" (copied to clipboard)"
        start $script:veraCryptRootDir
        . $downloadPath
        WaitWhileProcess *VeraCrypt*
    } {
        $script:veraCryptRootDir = "$OneDrive\Ben\Programs\VeraCrypt"
        $script:veraCryptOldVersion = Get-ChildItem $script:veraCryptRootDir -Directory -Exclude Current | sort Name | select -Last 1 | Split-Path -Leaf
        $script:veraCryptNewVersion = (winget show IDRIX.VeraCrypt | sls "(?<=Version: ).*").Matches.Value
        Write-Host "Old VeraCrypt version: $script:veraCryptOldVersion"
        Write-Host "New VeraCrypt version: $script:veraCryptNewVersion"
        $script:veraCryptNewVersion -eq $script:veraCryptOldVersion
    }

    InstallFromWingetBlock Microsoft.PowerToys {
        Copy-Item2 $PSScriptRoot\..\programs\PowerToys.settings.json $env:LocalAppData\Microsoft\PowerToys\settings.json
        Copy-Item2 $PSScriptRoot\..\programs\PowerToys.VideoConference.settings.json "$env:LocalAppData\Microsoft\PowerToys\Video Conference\settings.json"
        Copy-Item2 $PSScriptRoot\..\programs\PowerToys.ColorPicker.settings.json "$env:LocalAppData\Microsoft\PowerToys\ColorPicker\settings.json"
    }

    Block "Install nanDECK" {
        Download-File ((iwr https://www.nandeck.com).Content | sls https://www\.nandeck\.com/download/\d+ | select -exp Matches | select -exp Value) $env:tmp\nandeck.zip
        Expand-Archive $env:tmp\nandeck.zip C:\BenLocal\Programs\nanDECK
        Copy-Item $PSScriptRoot\..\programs\nanDECK.ini C:\BenLocal\Programs\nanDECK\
        New-Shortcut C:\BenLocal\Programs\nanDECK\nanDECK.exe "$env:AppData\Microsoft\Windows\Start Menu\Programs\Ben\nanDECK.lnk"
    } {
        Test-Path C:\BenLocal\Programs\nanDECK
    }
}

if (!(Configured $forHtpc)) {
    InstallFromWingetBlock dotPDNLLC.paintdotnet
}

InstallFromWingetBlock VideoLAN.VLC {
    DeleteDesktopShortcut "VLC media player"
}

InstallFromWingetBlock JAMSoftware.TreeSize.Free

if (Configured $forKids) {
    InstallFromWingetBlock MITMediaLab.Scratch.3 {
        DeleteDesktopShortcut "Scratch 3"
    }
}

if (Configured $forHome, $forKids, $forTest) {
    Block "Install Cricut Design Space" {
        $fileName = (iwr https://s3-us-west-2.amazonaws.com/staticcontent.cricut.com/a/software/win32-native/latest.json | ConvertFrom-Json).rolloutInstallFile
        $downloadUrl = (iwr "https://apis.cricut.com/desktopdownload/InstallerFile?shard=a&operatingSystem=win32native&fileName=$fileName" | ConvertFrom-Json).result
        Download-File $downloadUrl $env:tmp\$fileName
        . $env:tmp\$fileName
        DeleteDesktopShortcut "Cricut Design Space"
    } {
        Test-ProgramInstalled "Cricut Design Space"
    }
}

& $PSScriptRoot\games.ps1
