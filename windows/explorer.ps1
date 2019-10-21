& '.\windows\Hide Folders Section in This PC.ps1'
& '.\windows\Associate Extensionless Files with VS Code.ps1'
Create-Shortcut -Target "$env:LocalAppData\Programs\Microsoft VS Code\Code.exe" -Link "$((New-Object -ComObject WScript.Shell).SpecialFolders.Item("sendto"))\nCode.lnk"
