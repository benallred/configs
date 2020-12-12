FirstRunBlock "Devices > Printers & scanners > Add a printer or scanner > The printer that I want isn't listed" {
    if (!(Configured $forHome)) {
        Write-ManualStep "Select a shared printer by name = \\{Server}\{Printer}"
        rundll32 printui.dll PrintUIEntry /im
        while (Get-Process rundll32 -ErrorAction Ignore) {
            Write-Host -ForegroundColor Yellow "Waiting for rundll32 to close"
            sleep -s 10
        }
    }
}
