Block "Prevent `"Allow my organization to manage my device`"" {
    Set-RegistryValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WorkplaceJoin" -Name BlockAADWorkplaceJoin -Value 1
}

if ((Configured $forWork) -or (Configured $forTest)) {
    InstallFromWingetBlock Mozilla.Firefox {
        DeleteDesktopShortcut Firefox
    }

    Block "Install Tor Browser" {
        winget install --id TorProject.TorBrowser
        Move-Item "$env:UserProfile\Desktop\Tor Browser" C:\BenLocal\Programs
    } {
        Test-Path "C:\BenLocal\Programs\Tor Browser"
    }

    Block "Uninstall Lenovo Quick Clean" {
        winget uninstall "Lenovo Quick Clean"
    } {
        !(winget list "Lenovo Quick Clean" | sls "Lenovo Quick Clean")
    }

    InstallFromWingetBlock 9WZDNCRFJBLK # Arc Touch Bluetooth Mouse

    InstallFromWingetBlock Zoom.Zoom {
        DeleteDesktopShortcut Zoom

        # Configure during install:
        #   https://support.zoom.us/hc/en-us/articles/201362163-Mass-Installation-and-Configuration-for-Windows#h_b82f0349-4d8f-45dd-898a-1ab98389a4b7
        #   Code
        #       Download-File https://zoom.us/client/latest/ZoomInstallerFull.msi $env:tmp\ZoomInstallerFull.msi
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

    InstallFromWingetBlock Microsoft.Teams {
        DeleteDesktopShortcut "Microsoft Teams (work or school)"
        # Teams does not seem to pick up manual changes to the settings file
        # $teamsSettings = Get-Content $env:AppData\Microsoft\Teams\desktop-config.json | ConvertFrom-Json
        # $teamsSettings | Add-Member NoteProperty theme "darkV2" -Force
        # ConvertTo-Json $teamsSettings | Set-Content $env:AppData\Microsoft\Teams\desktop-config.json
        Write-ManualStep "General > Theme = Dark"
        Write-ManualStep "Privacy > Surveys = Off"
    }

    Block "Outlook > Options > Add-ins > Manage COM Add-ins > Mimecast for Outlook = Off" {
        Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Office\Outlook\Addins\MimecastServicesForOutlook.AddinModule" -Name ADXStartMode -Value FIRSTSTART
        Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Office\Outlook\Addins\MimecastServicesForOutlook.AddinModule" -Name LoadBehavior -Value 2
    }

    Block "Other Visual Studio Components" {
        # Microsoft.VisualStudio.ComponentGroup.IISDevelopment    Development time IIS support
        winget install --id Microsoft.VisualStudio.2022.Community --accept-package-agreements --override "--passive --norestart --wait --add Microsoft.VisualStudio.ComponentGroup.IISDevelopment"
    } {
        . "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -format value -requires Microsoft.VisualStudio.ComponentGroup.IISDevelopment
    }

    InstallVisualStudioExtensionBlock TechTalkSpecFlowTeam SpecFlowForVisualStudio2022

    InstallFromWingetBlock Amazon.AWSCLI {
        Add-Content -Path $profile {
            Register-ArgumentCompleter -Native -CommandName aws, awslocal -ScriptBlock {
                param($wordToComplete, $commandAst, $cursorPosition)
                $env:COMP_LINE = $commandAst
                $env:COMP_POINT = $cursorPosition
                . "$env:ProgramFiles\Amazon\AWSCLIV2\aws_completer.exe" | ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
                }
                Remove-Item Env:\COMP_LINE
                Remove-Item Env:\COMP_POINT
            }
        }
    }

    Block "Install Microsoft.dotnet 5" {
        winget install Microsoft.dotnet --version (winget show Microsoft.dotnet --versions | ? { $_ -like "5*" } | sort -d -t 1)
    } {
        winget list Microsoft.dotnet -e | sls (winget show Microsoft.dotnet --versions | ? { $_ -like "5*" } | sort -d -t 1)
    }

    Block "Set Elasticsearch Docker settings" {
        Set-Content $env:UserProfile\.wslconfig "[wsl2]", "kernelCommandLine=sysctl.vm.max_map_count=262144"
    }
}
