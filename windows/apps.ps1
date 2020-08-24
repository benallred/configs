FirstRunBlock "Configure OneNote" {
    Write-ManualStep "Start OneNote notebooks syncing"
    start onenote:
}

FirstRunBlock "Connect phone" {
    Write-ManualStep "Connect phone"
    start ms-phone:
}
