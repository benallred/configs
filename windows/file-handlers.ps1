Block "Associate extensionless files with VS Code" {
    & "$PSScriptRoot\Associate Extensionless Files with VS Code.ps1"
}

Block "Create generic file handler" {
    Set-RegistryValue "HKLM:\SOFTWARE\Classes\Ben.VSCode\shell\open\command" -Value """$env:LocalAppData\Programs\Microsoft VS Code\Code.exe"" ""%1"""
}

function AssociateFileBlock([string]$Extension, [string]$Handler) {
    Block "Associate $Extension with $Handler" {
        Set-RegistryValue "HKCU:\SOFTWARE\Classes\.$($Extension.Trim('.'))" -Value $Handler
    }
}

AssociateFileBlock xml VSCodeSourceFile
AssociateFileBlock DotSettings VSCodeSourceFile
AssociateFileBlock creds VSCodeSourceFile
AssociateFileBlock pgpass VSCodeSourceFile
AssociateFileBlock yarnrc VSCodeSourceFile
AssociateFileBlock nvmrc VSCodeSourceFile
