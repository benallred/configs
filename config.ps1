param([switch]$DryRun, [switch]$SkipBackup, [string]$Run)

. $PSScriptRoot\config-functions.ps1
mkdir C:\BenLocal\backup -ErrorAction Ignore

Block "Configure for" {
    $forHome = "home"
    $forWork = "work"
    $forTest = "test"
    while (($configureFor = (Read-Host "Configure for ($forHome,$forWork,$forTest)")) -notin @($forHome, $forWork, $forTest)) { }
    if (!(Test-Path $profile)) {
        New-Item $profile -Force
    }
    Add-Content -Path $profile -Value "`n"
    Add-Content -Path $profile -Value "`$forHome = `"$forHome`""
    Add-Content -Path $profile -Value "`$forWork = `"$forWork`""
    Add-Content -Path $profile -Value "`$forTest = `"$forTest`""
    Add-Content -Path $profile -Value "`$configureFor = `"$configureFor`""
    Add-Content -Path $profile -Value "`$configure = { `$args[0] -eq `$configureFor }"
} {
    (Test-Path $profile) -and (Select-String "\`$configureFor" $profile) # -Pattern is regex
}
if (!$DryRun -and !$Run) { . $profile } # make profile available to scripts below

Block "Backup Registry" {
    if (!(& $configure $forTest)) {
        & $PSScriptRoot\backup-registry.ps1
    }
} {
    $SkipBackup
}

& $PSScriptRoot\powershell\config.ps1
if (!$DryRun -and !$Run) { . $profile } # make profile available to scripts below

Block "Git config" {
    git config --global --add include.path $PSScriptRoot\git\ben.gitconfig
} {
    (git config --get-all --global include.path) -match "ben\.gitconfig"
}

& $PSScriptRoot\windows\config.ps1
& $PSScriptRoot\install\install.ps1
& $PSScriptRoot\scheduled-tasks\config.ps1

FirstRunBlock "Start Menu and Taskbar items" {
    # The layout XML will not import with comments
    # https://docs.microsoft.com/en-us/windows/configuration/configure-windows-10-taskbar
    # https://docs.microsoft.com/en-us/windows/configuration/start-layout-xml-desktop
    # C:\Users\Default\AppData\Local\Microsoft\Windows\Shell\DefaultLayouts.xml
    # Get AppUserModelID: Get-StartApps

    # PinListPlacement="Replace" in layout XML appears to clear icons only if they are not being added again
    # It does not appear to clear icons _then_ add those listed; just removes those not listed and adds new ones
    # This results in icons not getting ordered correctly
    # So first import an empty layout to force removal of all icons
    Import-StartLayout $PSScriptRoot\windows\StartAndTaskbarLayout-Empty.xml $env:SystemDrive\
    # Some items are left on the taskbar (for example, Microsoft Edge Dev) but with a broken link
    # Clearing this registry key removes those and the key is recreated with default values when explorer.exe starts
    Remove-Item "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband" -Recurse
    # This doesn't have to be done to get the correct items pinned
    # But when items are pinned, shortcuts are created in this folder
    # If they already exist, they are given the standard (1), (2), etc suffixes
    # By clearing this folder, it ensures the new pinned items are not duplicates and have nicer names when hovering over them
    Remove-item "$env:AppData\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\*"
    # When immediately importing the desired layout after clearing, the old settings don't seem to get cleared
    # Let explorer load the cleared settings
    Stop-Process -Name explorer
    # When immediately importing the desired layout after stopping explorer, the old settings don't seem to get cleared
    # We probably imported before explorer finished starting
    $sleepSeconds = 10
    Write-Output "Sleeping $sleepSeconds seconds"
    sleep -s $sleepSeconds
    # Initialize Photos app so live tile will work
    # Tried doing this at the end, but if explorer.exe is not started up yet, it generates an error
    #   start : This command cannot be run due to the error: Unknown error (0x87b20c15).
    start ms-photos:
    # There are multiple ways to pin Edge Dev (various .lnk's or the .exe)
    # When clicking the taskbar item, however, Edge starts as a new taskbar item, not in the place it was clicked from
    # I think it is because the process that actually starts has a flag being passed to the exe (--profile-directory=Default)
    # The only .lnk I can find that is passing this flag is in a place with what seems like a random identifier
    # So copy that .lnk to a place I can count on when pinning it
    Copy-Item (Get-ChildItem "$env:AppData\Microsoft\Internet Explorer\Quick Launch\User Pinned\ImplicitAppShortcuts" "Microsoft Edge Dev.lnk" -Recurse).FullName "$env:AppData\Microsoft\Windows\Start Menu\Programs\BenCommands"
    # The start menu is not updated when importing the desired layout
    # Clearing this registry key solves that and the key is recreated with default values when explorer.exe starts
    Remove-Item "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount" -Recurse
    # Import desired layout
    Import-StartLayout $PSScriptRoot\windows\StartAndTaskbarLayout.xml $env:SystemDrive\
    # Generally trying to avoid restarting explorer during configuration and just letting everything get reloaded on reboot
    # This is not required (surprising! given what we have to go through above) and the desired layout gets applied on reboot
    # But we are already having to restart explorer during this block anyway and this makes testing or re-configuring easier
    Stop-Process -Name explorer
}
