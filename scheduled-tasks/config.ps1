if (& $configure $forHome) {
    & $PSScriptRoot\home\config.ps1
}
elseif (& $configure $forWork) {
    & $PSScriptRoot\work\config.ps1
}
