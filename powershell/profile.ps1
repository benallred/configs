$OneDrive = "$env:UserProfile\OneDrive"
$git = "C:\BenLocal\git"

function SetWindowTitle($title)
{
	$GitPromptSettings.EnableWindowTitle = ""
	$Host.UI.RawUI.WindowTitle = $title
}

function ResetWindowTitle($title)
{
	$GitPromptSettings.EnableWindowTitle = "Git:"
	$Host.UI.RawUI.WindowTitle = "PowerShell"
}

function Create-Shortcut($Target, $Link)
{
	$shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut($Link)
	$shortcut.TargetPath = $Target
	$shortcut.WorkingDirectory = Split-Path $Target
	$shortcut.Save()
}

$transcriptDir = "C:\BenLocal\PowerShell Transcripts"
Get-ChildItem "$transcriptDir\*.log" | ? { !(sls -Path $_ -Pattern "Command start time:" -SimpleMatch -Quiet) } | rm -ErrorAction SilentlyContinue
$Transcript = "$transcriptDir\$(Get-Date -Format o | % { $_ -replace ":", "_" }).log"
Start-Transcript $Transcript -NoClobber -IncludeInvocationHeader
