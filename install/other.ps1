if (Configured $forHome, $forWork, $forTest) {
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
