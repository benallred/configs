$OneDrive = "$env:UserProfile\OneDrive"

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

$transcriptDir = "C:\BenLocal\PowerShell Transcripts"
Get-ChildItem "$transcriptDir\*.log" | ? { !(sls -Path $_ -Pattern "Command start time:" -SimpleMatch -Quiet) } | rm -ErrorAction SilentlyContinue
$Transcript = "$transcriptDir\$(Get-Date -Format o | % { $_ -replace ":", "_" }).log"
Start-Transcript $Transcript -NoClobber -IncludeInvocationHeader
