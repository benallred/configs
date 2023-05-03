Block "Prevent `"Allow my organization to manage my device`"" {
    Set-RegistryValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WorkplaceJoin" -Name BlockAADWorkplaceJoin -Value 1
}

InstallFromGitHubAssetBlock tom-englert RegionToShare RegionToShare.zip {
    Copy-Item2 .\* C:\BenLocal\Programs\RegionToShare -Recurse
    New-Shortcut C:\BenLocal\Programs\RegionToShare\RegionToShare.exe "$env:AppData\Microsoft\Windows\Start Menu\Programs\Ben\RegionToShare.lnk"
} {
    Test-Path C:\BenLocal\Programs\RegionToShare
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

    Block "Install Zoom" {
        # https://support.zoom.us/hc/en-us/articles/201362163-Mass-deploying-with-preconfigured-settings-for-Windows
        winget install Zoom.Zoom --scope machine --override `
        ('zNoDesktopShortCut="true"' + `
                ' ZRecommend="' + `
                'KeepSignedIn=1' + `
                ';AutoHideToolbar=0' + `
                ';EnableRemindMeetingTime=1' + `
                ';MuteWhenLockScreen=1' + `
                ';DisableVideo=1' + `
                ';AlwaysShowVideoPreviewDialog=0' + `
                ';SetUseSystemDefaultMicForVoip=1' + `
                ';SetUseSystemDefaultSpeakerForVoip=1' + `
                ';AutoJoinVOIP=1' + `
                ';MuteVoipWhenJoin=1' + `
                ';AutoFullScreenWhenViewShare=0' + `
                '"')

        . $env:ProgramFiles\Zoom\bin\Zoom.exe
        WaitForPath $env:AppData\Zoom\data\Zoom.us.ini
        Add-Content $env:AppData\Zoom\data\Zoom.us.ini "com.zoom.client.theme.mode=3"

        Write-ManualStep "Settings > Share Screen > Share applications = Share all windows from an application"
        Write-ManualStep "Settings > Keyboard Shortcuts > Meeting > Start/Stop Screen Sharing = Enable Global Shortcut"
        Write-ManualStep "Settings > Keyboard Shortcuts > Meeting > End Meeting = Enable Global Shortcut"
    } {
        winget list Zoom.Zoom -e | sls Zoom.Zoom
    }

    if (!(Configured $forTest)) {
        InstallFromWingetBlock Docker.DockerDesktop {
            DeleteDesktopShortcut "Docker Desktop"
            RemoveStartupRegistryKey "Docker Desktop"
            WaitForPath $env:AppData\Docker\settings.json
            $dockerSettings = Get-Content $env:AppData\Docker\settings.json | ConvertFrom-Json
            $dockerSettings | Add-Member NoteProperty openUIOnStartupDisabled $true
            ConvertTo-Json $dockerSettings | Set-Content $env:AppData\Docker\settings.json
        }
    }

    InstallFromGitHubBlock benallred dc {
        if (!(Test-Path $profile) -or !(Select-String "dc\.ps1" $profile)) {
            Add-Content -Path $profile -Value "`n"
            Add-Content -Path $profile -Value ". $git\dc\dc.ps1"
        }
    }

    InstallFromScoopBlock mob

    InstallFromWingetBlock JetBrains.Rider {
        WaitForPath "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\JetBrains\JetBrains Rider *.lnk"
        . "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\JetBrains\JetBrains Rider *.lnk"
    }

    Block "Configure Rider" {
        WaitForPath $env:AppData\JetBrains\Rider*
        $riderSettingsBaseDir = Get-ChildItem $env:AppData\JetBrains Rider* | sort Name | select -Last 1

        $globalDotSettingsPath = "$riderSettingsBaseDir\resharper-host\GlobalSettingsStorage.DotSettings"
        WaitForPath $globalDotSettingsPath
        $settingsFileGuid = (New-Guid).ToString("N").ToUpper()
        $dotSettings = Get-Content $globalDotSettingsPath -Raw
        if ($dotSettings -notlike "*Rider.DotSettings*") {
            $dotSettings = $dotSettings -replace '\</wpf:ResourceDictionary\>', @"

            <s:Boolean x:Key="/Default/Environment/InjectedLayers/FileInjectedLayer/=$settingsFileGuid/@KeyIndexDefined">True</s:Boolean>
            <s:String x:Key="/Default/Environment/InjectedLayers/FileInjectedLayer/=$settingsFileGuid/AbsolutePath/@EntryValue">$git\configs\programs\Rider.DotSettings</s:String>
            <s:Boolean x:Key="/Default/Environment/InjectedLayers/InjectedLayerCustomization/=File$settingsFileGuid/@KeyIndexDefined">True</s:Boolean>
            <s:Double x:Key="/Default/Environment/InjectedLayers/InjectedLayerCustomization/=File$settingsFileGuid/RelativePriority/@EntryValue">1</s:Double>
        </wpf:ResourceDictionary>
"@
            Set-Content $globalDotSettingsPath $dotSettings
        }

        function SetMachineSetting($SettingFile, $ComponentName, $Name, $Value) {
            $settings = [xml](Get-Content "$riderSettingsBaseDir\options\$SettingFile.xml" -ErrorAction Ignore)
            if (!$settings) {
                $settings = [xml]"<application><component name=`"$ComponentName`"></component></application>"
            }
            $component = $settings.application.component | ? { $_.name -eq $ComponentName }
            if (!$component) {
                $component = $settings.CreateElement("component")
                $component.SetAttribute("name", $ComponentName)
                $settings.application.AppendChild($component)
            }
            $option = $component.option | ? { $_.name -eq $Name }
            if (!$option) {
                $option = $settings.CreateElement("option")
                $option.SetAttribute("name", $Name)
                $option.SetAttribute("value", $Value)
                $component.AppendChild($option)
            }
            else {
                $option.value = $Value
            }
            if (!(Test-Path $riderSettingsBaseDir\options)) {
                New-Item $riderSettingsBaseDir\options -ItemType Directory -Force | Out-Null
            }
            $settings.Save("$riderSettingsBaseDir\options\$SettingFile.xml")
        }

        SetMachineSetting editor EditorSettings IS_WHITESPACES_SHOWN true
        SetMachineSetting editor EditorSettings USE_EDITOR_FONT_IN_INLAYS true
        SetMachineSetting editor EditorSettings SHOW_BREADCRUMBS false
        SetMachineSetting editor CodeInsightSettings PARAMETER_INFO_DELAY 0
        SetMachineSetting editor CodeFoldingSettings COLLAPSE_IMPORTS false
        SetMachineSetting ui.lnf UISettings SCROLL_TAB_LAYOUT_IN_EDITOR false
        SetMachineSetting ui.lnf UISettings SHOW_PINNED_TABS_IN_A_SEPARATE_ROW true
        SetMachineSetting ui.lnf UISettings MARK_MODIFIED_TABS_WITH_ASTERISK true
        SetMachineSetting ui.lnf UISettings SHOW_CLOSE_BUTTON false
        SetMachineSetting ui.lnf UISettings OPEN_TABS_AT_THE_END true
        SetMachineSetting ui.lnf UISettings EDITOR_TAB_LIMIT 100
        SetMachineSetting editor CodeVisionSettings enabled false
        SetMachineSetting ide.general GeneralSettings confirmExit false
        SetMachineSetting ide.general GeneralSettings confirmOpenNewProject2 0

        if (!(Test-Path $riderSettingsBaseDir\plugins\AceJump)) {
            Download-File https://plugins.jetbrains.com/files/$((Invoke-RestMethod "https://plugins.jetbrains.com/api/plugins/7086/updates?size=1").file) $env:tmp\AceJump.zip
            Expand-Archive $env:tmp\AceJump.zip $riderSettingsBaseDir\plugins
        }
        SetMachineSetting AceJump AceConfig layout COLEMK
    }

    InstallPowerShellModuleBlock Az
}
