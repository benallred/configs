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

    InstallFromWingetBlock 9WZDNCRFJBLK # Arc Touch Bluetooth Mouse

    InstallFromWingetBlock Zoom.Zoom `
        'zNoDesktopShortCut="true"' + `
        ' ZRecommend="' + `
        'AutoHideToolbar=0' + `
        ';EnableRemindMeetingTime=1' + `
        ';MuteWhenLockScreen=1' + `
        ';DisableVideo=1' + `
        ';AlwaysShowVideoPreviewDialog=0' + `
        ';SetUseSystemDefaultMicForVoip=1' + `
        ';SetUseSystemDefaultSpeakerForVoip=1' + `
        ';AutoJoinVOIP=1' + `
        ';MuteVoipWhenJoin=1' + `
        ';AutoFullScreenWhenViewShare=0' + `
        '"' `
    {
        . $env:ProgramFiles\Zoom\bin\Zoom.exe
        WaitForPath $env:AppData\Zoom\data\Zoom.us.ini
        Add-Content $env:AppData\Zoom\data\Zoom.us.ini "com.zoom.client.theme.mode=3"
    }

    InstallFromScoopBlock mob

    InstallFromWingetBlock JetBrains.Rider

    InstallPowerShellModuleBlock Az
}
