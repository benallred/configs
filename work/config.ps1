if ((Configured $forWork) -or (Configured $forTest)) {
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

    Block "Outlook > Options > Add-ins > Manage COM Add-ins > Mimecast for Outlook = Off" {
        Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Office\Outlook\Addins\MimecastServicesForOutlook.AddinModule" -Name ADXStartMode -Value FIRSTSTART
        Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Office\Outlook\Addins\MimecastServicesForOutlook.AddinModule" -Name LoadBehavior -Value 2
    }

    Block "Install SQL Server" {
        # https://docs.microsoft.com/en-us/sql/database-engine/install-windows/install-sql-server-from-the-command-prompt
        # Download-File https://go.microsoft.com/fwlink/?linkid=866662 $env:tmp\SQL2019-SSEI-Dev.exe
        Download-File https://go.microsoft.com/fwlink/?linkid=853016 $env:tmp\SQLServer2017-SSEI-Dev.exe
        $installArgs = "/Action=Install", "/IAcceptSqlServerLicenseTerms", "/InstallPath=`"C:\Program Files\Microsoft SQL Server`"", "/Features=FullText", "/SecurityMode=SQL", "/Verbose"
        Start-Process $env:tmp\SQLServer2017-SSEI-Dev.exe $installArgs -Wait -PassThru
    } {
        Test-ProgramInstalled "SQL Server 2017"
    }
}
