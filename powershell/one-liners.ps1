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

function ppl() {
    Copy-Item $env:OneDrive\Music\Playlists $tmp\BeforePlexExport_$(Get-TimestampForFileName) -Recurse -Filter *.m3u
    & $git\plex-playlist-liberator\plex-playlist-liberator.ps1 -Export -Destination $env:OneDrive\Music\Playlists
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
