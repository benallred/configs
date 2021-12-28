$visualStudioVersionKey = Get-ChildItem "HKCU:\Software\Microsoft\VisualStudio" | ? { $_.PSChildName -match "^\d\d.\d_" } | Select-Object -Last 1
Set-ItemProperty Registry::$visualStudioVersionKey -Name UseSolutionNavigatorGraphProvider -Value 0

$env:LocalAppData\Microsoft\VisualStudio\17.0_658d25fa\privateregistry.bin
