Block "Register the default repository for PowerShell modules" {
    Register-PSRepository -Default
}

Block "Install posh-git" {
    Install-Module posh-git -Force
    Add-PoshGitToProfile -AllHosts
} {
    Get-Module -ListAvailable posh-git
}

Block "Install oh-my-posh" {
    Install-Module oh-my-posh -Scope CurrentUser -AllowPrerelease -Force
} {
    Get-Module -ListAvailable oh-my-posh
}

if (!(Configured $forKids)) {
    Block "Install BurntToast" {
        Install-Module BurntToast -Force
    } {
        Get-Module -ListAvailable BurntToast
    }
}

Block "PowerShell Transcripts" {
    mkdir "C:\BenLocal\PowerShell Transcripts" -ErrorAction Ignore
}

Block "Configure profile.ps1" {
    Add-Content -Path $profile -Value "`n. $PSScriptRoot\profile.ps1"
} {
    (Test-Path $profile) -and (Select-String "$($PSScriptRoot -replace "\\", "\\")\\profile.ps1" $profile) # <original> is regex, <substitute> is PS string
}

Block "Configure winget" {
    Add-Content -Path $profile {
        Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
            param($wordToComplete, $commandAst, $cursorPosition)
            [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
            $Local:word = $wordToComplete.Replace('"', '""')
            $Local:ast = $commandAst.ToString().Replace('"', '""')
            winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
                [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
            }
        }
    }
} {
    (Test-Path $profile) -and (Select-String "Register-ArgumentCompleter.*winget" $profile)
}

Block "Install scoop" {
    iwr get.scoop.sh | iex
} {
    Get-Command scoop -ErrorAction Ignore
}

Block "Configure scoop nerd-fonts bucket" {
    scoop bucket add nerd-fonts
} {
    scoop bucket list | Select-String nerd-fonts
}

InstallFromScoopBlock "Cascadia Code" CascadiaCode-NF

if (!(Configured $forTest)) {
    FirstRunBlock "Update PS help" {
        Update-Help -ErrorAction Ignore
    }
}
