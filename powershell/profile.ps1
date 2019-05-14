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