Block "Associate extensionless files with VS Code" {
    & "$PSScriptRoot\Associate Extensionless Files with VS Code.ps1"
}

Block "Create generic file handler" {
    $hkcr = [Microsoft.Win32.RegistryKey]::OpenBaseKey("ClassesRoot", "Default")
    $handlerKey = $hkcr.CreateSubKey("Ben.VSCode")
    $commandKey = $handlerKey.CreateSubKey("shell\open\command")
    $commandKey.SetValue("", """$env:LocalAppData\Programs\Microsoft VS Code\Code.exe"" ""%1""")
}

function AssociateFileBlock([string]$Extension, [string]$Handler) {
    Block "Associate $Extension with $Handler" {
        $hkcr = [Microsoft.Win32.RegistryKey]::OpenBaseKey("ClassesRoot", "Default")
        $extensionKey = $hkcr.CreateSubKey(".$($Extension.Trim('.'))")
        $extensionKey.SetValue("", $Handler)
    }
}

AssociateFileBlock xml VSCodeSourceFile
AssociateFileBlock DotSettings VSCodeSourceFile
AssociateFileBlock creds VSCodeSourceFile
AssociateFileBlock pgpass VSCodeSourceFile
AssociateFileBlock yarnrc VSCodeSourceFile
AssociateFileBlock nvmrc VSCodeSourceFile
