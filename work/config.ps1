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

    InstallFromWingetBlock JetBrains.Rider {
        WaitForPath "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\JetBrains\JetBrains Rider *.lnk"
        . "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\JetBrains\JetBrains Rider *.lnk"
        WaitForPath $env:AppData\JetBrains\Rider*
        $globalDotSettingsPath = "$(Get-ChildItem $env:AppData\JetBrains Rider* | sort Name | select -Last 1)\resharper-host\GlobalSettingsStorage.DotSettings"
        WaitForPath $globalDotSettingsPath
        $settingsFileGuid = (New-Guid).ToString("N").ToUpper()
        $dotSettings = Get-Content $globalDotSettingsPath -Raw
        $dotSettings = $dotSettings -replace '\</wpf:ResourceDictionary\>', @"

            <s:Boolean x:Key="/Default/Environment/InjectedLayers/FileInjectedLayer/=$settingsFileGuid/@KeyIndexDefined">True</s:Boolean>
            <s:String x:Key="/Default/Environment/InjectedLayers/FileInjectedLayer/=$settingsFileGuid/AbsolutePath/@EntryValue">$git\configs\programs\Rider.DotSettings</s:String>
            <s:Boolean x:Key="/Default/Environment/InjectedLayers/InjectedLayerCustomization/=File$settingsFileGuid/@KeyIndexDefined">True</s:Boolean>
            <s:Double x:Key="/Default/Environment/InjectedLayers/InjectedLayerCustomization/=File$settingsFileGuid/RelativePriority/@EntryValue">1</s:Double>
        </wpf:ResourceDictionary>
"@
        Set-Content $globalDotSettingsPath $dotSettings
    }

    InstallPowerShellModuleBlock Az
}
