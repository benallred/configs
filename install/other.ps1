if (Configured $forHome, $forWork, $forTest) {
    InstallFromWingetBlock Genymobile.scrcpy

    InstallFromWingetBlock Ookla.Speedtest.CLI {
        speedtest --accept-license --version
    }

    InstallFromWingetBlock Rufus.Rufus {
        New-StartMenuShortcut (Get-ChildItem "$env:LocalAppData\Microsoft\WinGet\Packages\Rufus.Rufus_Microsoft.Winget.Source_8wekyb3d8bbwe" rufus*.exe) Rufus
    }

    Block "Install nanDECK" {
        start https://nandeck.com
        Write-ManualStep "Copy link to installer"
        $downloadUrl = Read-Host "Installer link"
        Download-File $downloadUrl $env:tmp\nanDECK_installer.zip
        Expand-Archive $env:tmp\nanDECK_installer.zip $env:tmp
        Start-Process $env:tmp\nanDECK_installer.exe "/silent" -Wait
        Copy-Item $PSScriptRoot\..\programs\nanDECK.ini $env:AppData\nanDECK\
    } {
        Test-ProgramInstalled nanDECK
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
