Write-Output ("*" * $Host.UI.RawUI.WindowSize.Width)
Write-Output "Deleting desktop shortcuts"
Get-Content C:\BenLocal\.delete-desktop-shortcuts.txt | % {
    Write-Output "`t$_"
    Remove-Item "$env:Public\Desktop\$_.lnk" -ErrorAction Ignore
    Remove-Item "$env:UserProfile\Desktop\$_.lnk" -ErrorAction Ignore
}
