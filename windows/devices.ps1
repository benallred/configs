FirstRunBlock "Devices > Printers & scanners > Add a printer or scanner > The printer that I want isn't listed" {
    if (!(Configured $forHome)) {
        Write-ManualStep "Select a shared printer by name = \\{Server}\{Printer}"
        rundll32 printui.dll PrintUIEntry /im
        WaitWhileProcess rundll32
    }
}
