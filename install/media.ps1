InstallFromWingetBlock VideoLAN.VLC {
    DeleteDesktopShortcut "VLC media player"
}

if (Configured $forHome) {
    FirstRunBlock "Wait for Plex backup restore" {
        WaitForPath "HKCU:\SOFTWARE\PlexPlaylistLiberator"
    }
    InstallFromWingetBlock Plex.PlexMediaServer

    Block "Install OverDrive" {
        Download-File https://static.od-cdn.com/ODMediaConsoleSetup.msi $env:tmp\ODMediaConsoleSetup.msi
        Start-Process $env:tmp\ODMediaConsoleSetup.msi /passive, /norestart -Wait
        DeleteDesktopShortcut "OverDrive for Windows"
        Set-RegistryValue "HKCU:\Software\OverDrive, Inc.\OverDrive Media Console\Settings" "DownloadFolder-MP3 Audiobook" "C:\BenLocal\Audio Books"
    } {
        Test-ProgramInstalled "OverDrive for Windows"
    }
}

if (!(Configured $forHtpc)) {
    InstallFromWingetBlock Plex.Plexamp {
        DeleteDesktopShortcut Plexamp
        ConfigureNotifications tv.plex.plexamp ShowInActionCenter $false
        Copy-Item2 $PSScriptRoot\..\programs\Plexamp.MainWindow.json $env:AppData\Plexamp\MainWindow.json
        Write-ManualStep "Sign in to Plexamp"
        . $env:LocalAppData\Programs\Plexamp\Plexamp.exe
    } -NoUpdate

    InstallFromWingetBlock dotPDNLLC.paintdotnet
}

if (Configured $forHome, $forWork, $forTest) {
    if (!(Test-IsArm)) {
        InstallFromWingetBlock SergeySerkov.TagScanner {
            DeleteDesktopShortcut TagScanner
            New-Item $env:AppData\TagScanner -ItemType Directory
            Copy-Item $PSScriptRoot\..\programs\Tagscan.ini $env:AppData\TagScanner
        }
    }

    InstallFromWingetBlock yt-dlp.yt-dlp

    Block "Install Python" {
        $latestPython = winget search Python | sls "Python\.Python\.\d+\.(\d+)" | % { @{ id = $_.Matches.Value; sort = [int]$_.Matches.Groups[1].Value } } | sort sort -Descending | select -First 1 -ExpandProperty id
        InstallFromWingetBlock $latestPython
    }

    Block "Install mutagen" {
        pip install mutagen
    }
}
