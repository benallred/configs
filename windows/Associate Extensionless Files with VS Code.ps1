$hkcr = [Microsoft.Win32.RegistryKey]::OpenBaseKey("ClassesRoot", "Default")

# Create handler
$handlerKey = $hkcr.CreateSubKey("Ben.Extensionless")
$handlerKey.SetValue("", "Extensionless")
$defaultIconKey = $handlerKey.CreateSubKey("DefaultIcon")
$defaultIconKey.SetValue("", "%SystemRoot%\system32\shell32.dll,271")
$commandKey = $handlerKey.CreateSubKey("shell\open\command")
$commandKey.SetValue("", """$env:LocalAppData\Programs\Microsoft VS Code\Code.exe"" ""%1""")

# Associate extensionless files with handler
$extensionlessKey = $hkcr.CreateSubKey(".")
$extensionlessKey.SetValue("", "Ben.Extensionless")
