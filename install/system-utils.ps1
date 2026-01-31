InstallFromGitHubBlock benallred SnapX
Block "Start SnapX" {
    . $git\SnapX\SnapX.ahk
} {
    (Get-Process AutoHotkey -ErrorAction Ignore).CommandLine | sls SnapX.ahk
}

InstallFromWingetBlock voidtools.Everything {
    DeleteDesktopShortcut Everything
    $installFolder = (Test-IsArm) <# parens required #> `
        ? "$env:LocalAppData\Microsoft\WinGet\Packages\voidtools.Everything_Microsoft.Winget.Source_8wekyb3d8bbwe" `
        : "$env:ProgramFiles\Everything\"
    Copy-Item $PSScriptRoot\..\programs\Everything.ini $installFolder
    . $installFolder\Everything*.exe -install-run-on-system-startup
    . $installFolder\Everything*.exe -startup
    if (Test-IsArm) {
        New-StartMenuShortcut (Get-ChildItem $installFolder Everything*.exe) Everything
    }
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

InstallFromWingetBlock 9NBLGGH1ZBKW # Dynamic Theme

InstallFromWingetBlock JAMSoftware.TreeSize.Free

InstallFromScoopBlock sysinternals {
    Set-RegistryValue "HKCU:\Software\Sysinternals" EulaAccepted 1
}

if (Configured $forHome) {
    InstallFromWingetBlock CrashPlan.CrashPlanSMB {
        Write-ManualStep "Sign in"
        Write-ManualStep "Replace Existing"
        Write-ManualStep "Skip File Transfer"
    }
}

if (Configured $forHome, $forWork, $forTest) {
    InstallFromGitHubBlock benallred Bahk
    Block "Start Bahk" {
        . $git\Bahk\Ben.ahk
    } {
        (Get-Process AutoHotkey -ErrorAction Ignore).CommandLine | sls Ben.ahk
    }

    InstallFromWingetBlock Microsoft.PowerToys {
        Copy-Item2 $PSScriptRoot\..\programs\PowerToys.settings.json $env:LocalAppData\Microsoft\PowerToys\settings.json
        Copy-Item2 $PSScriptRoot\..\programs\PowerToys.ColorPicker.settings.json "$env:LocalAppData\Microsoft\PowerToys\ColorPicker\settings.json"
        Copy-Item2 $PSScriptRoot\..\programs\PowerToys.CommandPalette.settings.json "$env:LocalAppData\Packages\Microsoft.CommandPalette_8wekyb3d8bbwe\LocalState\settings.json"
        Copy-Item2 $PSScriptRoot\..\programs\PowerToys.FileLocksmith.settings.json "$env:LocalAppData\Microsoft\PowerToys\File Locksmith\file-locksmith-settings.json"
    }

    Block "Install RegFromApp" {
        Download-File https://www.nirsoft.net/utils/regfromapp-x64.zip $env:tmp\regfromapp-x64.zip
        Expand-Archive $env:tmp\regfromapp-x64.zip C:\BenLocal\Programs\RegFromApp64
        New-StartMenuShortcut C:\BenLocal\Programs\RegFromApp64\RegFromApp.exe RegFromApp64
        Download-File https://www.nirsoft.net/utils/regfromapp.zip $env:tmp\regfromapp.zip
        Expand-Archive $env:tmp\regfromapp.zip C:\BenLocal\Programs\RegFromApp
        New-StartMenuShortcut C:\BenLocal\Programs\RegFromApp\RegFromApp.exe RegFromApp
    } {
        Test-Path C:\BenLocal\Programs\RegFromApp64
    }

    function DownloadAndExtractVeraCrypt([string]$Version, [string]$TargetDir) {
        $downloadPath = "$veraCryptRootDir\VeraCrypt Portable $Version.exe"
        $versionDir = "$veraCryptRootDir\$Version"

        Download-File https://launchpad.net/veracrypt/trunk/$Version/+download/VeraCrypt%20Portable%20$Version.exe $downloadPath
        mkdir $versionDir | Out-Null
        $TargetDir | Set-Clipboard
        Write-ManualStep "Extract to `"$TargetDir`" (copied to clipboard)"
        start $veraCryptRootDir
        . $downloadPath
        WaitWhileProcess *VeraCrypt*
    }

    Block "Install VeraCrypt" {
        $version = (winget show IDRIX.VeraCrypt | sls "(?<=Version: ).*").Matches.Value
        $currentDir = "$veraCryptRootDir\Current"

        DownloadAndExtractVeraCrypt $version $currentDir
        New-StartMenuShortcut $currentDir\VeraCrypt-x64.exe VeraCrypt
    } {
        Test-Path "$veraCryptRootDir\Current"
    } {
        $script:veraCryptOldVersion = Get-ChildItem $veraCryptRootDir -Directory -Exclude Current | sort Name | select -Last 1 | Split-Path -Leaf
        $script:veraCryptNewVersion = (winget show IDRIX.VeraCrypt | sls "(?<=Version: ).*").Matches.Value
        Write-Host "Old VeraCrypt version: $script:veraCryptOldVersion"
        Write-Host "New VeraCrypt version: $script:veraCryptNewVersion"
        $script:veraCryptNewVersion -ne $script:veraCryptOldVersion
    } {
        $currentDir = "$veraCryptRootDir\Current"

        rm $veraCryptRootDir\$script:veraCryptOldVersion
        Rename-Item $currentDir $script:veraCryptOldVersion
        DownloadAndExtractVeraCrypt $script:veraCryptNewVersion $currentDir
    }

    InstallFromWingetBlock NickeManarin.ScreenToGif {
        DeleteDesktopShortcut ScreenToGif
        Copy-Item2 $PSScriptRoot\..\programs\ScreenToGif.xaml $env:AppData\ScreenToGif\Settings.xaml
    }
}
