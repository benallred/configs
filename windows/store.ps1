New-Item "HKLM:\Software\Policies\Microsoft\WindowsStore" -ErrorAction Ignore
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\WindowsStore" -Name AutoDownload -Value 2 # Update apps automatically = Off
