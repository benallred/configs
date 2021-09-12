##################################################
# QMK

function qmk-ps([Parameter(ValueFromRemainingArguments = $true)]$Rest) {
    C:\QMK_MSYS\shell_connector.cmd -c "qmk $Rest"
}

function flash() {
    qmk-ps compile -kb moonlander -km ben
    qmk-ps flash -kb moonlander -km ben
}

##################################################
# plex-playlist-liberator

function ppl([Parameter(Mandatory)][ValidateSet("Plex", "M3U")][string]$Master) {
    if ($Master -eq "Plex") {
        Copy-Item $env:OneDrive\Music\Playlists (tmpfor M3UBackup) -Recurse -Filter *.m3u
        & $git\plex-playlist-liberator\plex-playlist-liberator.ps1 -Export -Destination $env:OneDrive\Music\Playlists
    }
    else {
        & $git\plex-playlist-liberator\plex-playlist-liberator.ps1 -Export -Destination (tmpfor PlexBackup)
    }
    Set-Content $env:OneDrive\Music\Playlists\ToOrganize.m3u ""
    Write-Output "Scanning for orphans"
    $orphans = & $git\plex-playlist-liberator\plex-playlist-liberator.ps1 -ScanForOrphans -Source $env:OneDrive\Music\Playlists -MusicFolder $env:OneDrive\Music -Exclude *.mid, *.jpg, *.png, *.gif, *.txt, *.pdf, *.wpl, *.m3u, *.pdn, *.zip | select -Skip 1
    if ($orphans) {
        Write-Output "`tSaving to $env:OneDrive\Music\Playlists\ToOrganize.m3u"
        Set-Content $env:OneDrive\Music\Playlists\ToOrganize.m3u $orphans
    }
    & $git\plex-playlist-liberator\plex-playlist-liberator.ps1 -Sort -Source $env:OneDrive\Music\Playlists
    & $git\plex-playlist-liberator\plex-playlist-liberator.ps1 -Import -Source $env:OneDrive\Music\Playlists
}
