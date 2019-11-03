# Plex
Write-Output "Download and install Plex"
start https://www.plex.tv/media-server-downloads/

# NFO support
function InstallPlugin($githubRepo) {
    git clone https://github.com/$githubRepo.git "$env:LOCALAPPDATA\Plex Media Server\Plug-ins\$($githubRepo.split('/')[1])"
}

InstallPlugin gboudreau/XBMCnfoTVImporter.bundle
InstallPlugin gboudreau/XBMCnfoMoviesImporter.bundle
