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

& $PSScriptRoot\dev.ps1

if (Configured $forHome, $forWork, $forTest) {
    FirstRunBlock "Configure Edge" {
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
            ConfigureNotifications Microsoft.MicrosoftEdge.Dev_8wekyb3d8bbwe!https://calendar.google.com/ AllowUrgentNotifications $true
        }
    }
}

if (Configured $forHome, $forWork, $forTest) {
    InstallFromWingetBlock SlackTechnologies.Slack {
        . $env:ProgramFiles\Slack\slack.exe
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
        InstallFromWingetBlock Microsoft.Office "/configure $PSScriptRoot\OfficeConfiguration.M365.xml"
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
    # Options > Advanced > Editing > Include link to source when pasting from the Web = Off
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Office\16.0\OneNote\Options\Editing" -Name PasteIncludeURL -Value 0
    # UI Changes > Pin Notebook Pane to Side = Off
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Office\16.0\OneNote\Options\Other" -Name NavigationBarExpColState -Value 1
}

if (Configured $forHome, $forWork, $forTest) {
    InstallFromGitHubBlock benallred plex-playlist-liberator

    InstallFromGitHubBlock benallred YouTubeToPlex

    InstallFromGitHubBlock benallred DilbertImageDownloader

    InstallFromGitHubBlock benallred what-i-use

    InstallFromGitHubBlock benallred presentations

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

& $PSScriptRoot\devices.ps1

& $PSScriptRoot\system-utils.ps1

& $PSScriptRoot\media.ps1

if (Configured $forHome, $forWork, $forTest) {
    InstallFromWingetBlock Doist.Todoist {
        DeleteDesktopShortcut Todoist
    }

    InstallFromWingetBlock Genymobile.scrcpy

    InstallFromWingetBlock Ookla.Speedtest.CLI {
        speedtest --accept-license --version
    }

    InstallFromWingetBlock Rufus.Rufus {
        New-Shortcut (Get-ChildItem "$env:LocalAppData\Microsoft\WinGet\Packages\Rufus.Rufus_Microsoft.Winget.Source_8wekyb3d8bbwe" rufus*.exe) "$env:AppData\Microsoft\Windows\Start Menu\Programs\Ben\Rufus.lnk"
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
