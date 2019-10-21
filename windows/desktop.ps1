Set-ItemProperty "HKCU:\Software\Microsoft\Windows\Shell\Bags\1\Desktop" -Name IconSize -Value 32; Stop-Process -ProcessName explorer
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name SearchboxTaskbarMode -Value 0
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name ShowCortanaButton -Value 0
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\PenWorkspace" -Name PenWorkspaceButtonDesiredVisibility -Value 0
