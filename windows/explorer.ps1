Block "Hide Folders Section in This PC" {
    & "$PSScriptRoot\Hide Folders Section in This PC.ps1"
}
Block "Associate Extensionless Files with VS Code" {
    & "$PSScriptRoot\Associate Extensionless Files with VS Code.ps1"
}
Block "shell:sendto VS Code" {
    Create-Shortcut -Target "$env:LocalAppData\Programs\Microsoft VS Code\Code.exe" -Link "$((New-Object -ComObject WScript.Shell).SpecialFolders.Item("sendto"))\nCode.lnk"
}
