if (& $configure $forHome) {
    & $PSScriptRoot\home\config.ps1
}
else {
    & $PSScriptRoot\work\config.ps1
}
