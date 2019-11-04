while (($tasksToCreate = (Read-Host "Create home or work scheduled tasks (h/w)")) -notin @("h", "w")) { }

if ($tasksToCreate -eq "h") {
    & $PSScriptRoot\home\config.ps1
}
else {
    & $PSScriptRoot\work\config.ps1
}
