Block "Prevent `"Allow my organization to manage my device`"" {
    Set-RegistryValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WorkplaceJoin" -Name BlockAADWorkplaceJoin -Value 1
}

if ((Configured $forWork) -or (Configured $forTest)) {
    InstallFromMicrosoftStoreBlock "Arc Touch Bluetooth Mouse" 9wzdncrfjblk Microsoft.ArcTouchMouseSurfaceEditionSettings

    Block "Install Zoom" {
        Download-File https://zoom.us/client/latest/ZoomInstaller.exe $env:tmp\ZoomInstaller.exe
        . "$env:tmp\ZoomInstaller.exe"
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
    } {
        Test-ProgramInstalled Zoom
    }

    Block "Install Teams" {
        Download-File https://aka.ms/teamswin64 $env:tmp\Teams_windows_x64.exe
        . $env:tmp\Teams_windows_x64.exe
        DeleteDesktopShortcut "Microsoft Teams"
    } {
        Test-ProgramInstalled "Microsoft Teams"
    }

    Block "Outlook > Options > Add-ins > Manage COM Add-ins > Mimecast for Outlook = Off" {
        Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Office\Outlook\Addins\MimecastServicesForOutlook.AddinModule" -Name ADXStartMode -Value FIRSTSTART
        Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Office\Outlook\Addins\MimecastServicesForOutlook.AddinModule" -Name LoadBehavior -Value 2
    }

    InstallFromScoopBlock "AWS CLI" aws {
        Add-Content -Path $profile {
            Register-ArgumentCompleter -Native -CommandName aws -ScriptBlock {
                param($wordToComplete, $commandAst, $cursorPosition)
                $env:COMP_LINE = $commandAst
                $env:COMP_POINT = $cursorPosition
                . "$(scoop prefix aws)\aws_completer.exe" | ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
                }
                Remove-Item Env:\COMP_LINE
                Remove-Item Env:\COMP_POINT
            }
        }
    }

    Block "Install SQL Server" {
        # https://docs.microsoft.com/en-us/sql/database-engine/install-windows/install-sql-server-from-the-command-prompt
        # Download-File https://go.microsoft.com/fwlink/?linkid=866662 $env:tmp\SQL2019-SSEI-Dev.exe
        Download-File https://go.microsoft.com/fwlink/?linkid=853016 $env:tmp\SQLServer2017-SSEI-Dev.exe
        $installArgs = "/Action=Install", "/IAcceptSqlServerLicenseTerms", "/InstallPath=`"C:\Program Files\Microsoft SQL Server`"", "/Features=FullText", "/SecurityMode=SQL", "/Verbose"
        Start-Process $env:tmp\SQLServer2017-SSEI-Dev.exe $installArgs -Wait
    } {
        Test-ProgramInstalled "SQL Server 2017"
    }

    Block "Install SQL Server Management Studio" {
        # https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms
        Download-File https://aka.ms/ssmsfullsetup $env:tmp\SSMS-Setup-ENU.exe
        $installArgs = "/Passive", "/NoRestart"
        Start-Process $env:tmp\SSMS-Setup-ENU.exe $installArgs -Wait
    } {
        Test-ProgramInstalled "SQL Server Management Studio"
    }
}
