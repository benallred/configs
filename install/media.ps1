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

    InstallFromWingetBlock calibre.calibre

    Block "Install Adobe Digital Editions" {
        Download-File https://adedownload.adobe.com/pub/adobe/digitaleditions/ADE_4.5_Installer.exe $env:tmp\ADE_4.5_Installer.exe
        Start-Process $env:tmp\ADE_4.5_Installer.exe /S -Wait
        DeleteDesktopShortcut "Adobe Digital Editions 4.5"
        . "${env:ProgramFiles(x86)}\Adobe\Adobe Digital Editions 4.5\DigitalEditions.exe"
        Write-ManualStep "Help > Authorize Computer... (ctrl+shift+u)"
    } {
        Test-ProgramInstalled "Adobe Digital Editions"
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

    Block "Install mutagen" {
        pip install mutagen
    } {
        pip show mutagen 2>$null
    }
}
