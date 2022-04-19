function InstallPowerShellModuleBlock([string]$ModuleName, [scriptblock]$AfterInstall) {
    Block "Install $ModuleName" {
        Install-Module $ModuleName -Force
        if ($AfterInstall) {
            Invoke-Command $AfterInstall
        }
    } {
        Get-Module -ListAvailable $ModuleName
    } {
        (Find-Module $ModuleName).Version -gt (Get-Module $ModuleName -ListAvailable | sort Version -Descending | select -First 1).Version
    } {
        ReallyUpdate-Module $ModuleName
    }
}

Block "Update PSReadLine" {
    pwsh -NoProfile -c "Install-Module PSReadLine -Force"
    Remove-Module PSReadLine
    Import-Module PSReadLine
} {
    (Find-Module PSReadLine).Version -le (Get-Module PSReadLine).Version
}

Block "Install NuGet package provider for PowerShellGet" {
    Install-PackageProvider NuGet -Force
}

InstallPowerShellModuleBlock posh-git {
    Add-PoshGitToProfile -AllHosts
}

InstallFromWingetBlock JanDeDobbeleer.OhMyPosh

if (!(Configured $forKids)) {
    InstallPowerShellModuleBlock BurntToast
}

Block "PowerShell Transcripts" {
    mkdir "C:\BenLocal\PowerShell Transcripts" -ErrorAction Ignore
}

Block "Configure profile.ps1" {
    Add-Content -Path $profile -Value "`n. $PSScriptRoot\profile.ps1"
} {
    (Test-Path $profile) -and (Select-String "$($PSScriptRoot -replace "\\", "\\")\\profile.ps1" $profile) # <original> is regex, <substitute> is PS string
}

Block "Set winget as default terminal application" {
    $path = "HKCU:\Console\%%Startup"
    if (!(Test-Path $path)) {
        New-Item $path -Force | Out-Null
    }
    Set-ItemProperty $path -Name DelegationConsole -Value "{2EACA947-7F5F-4CFA-BA87-8F7FBEEFBE69}"
    Set-ItemProperty $path -Name DelegationTerminal -Value "{E12CFF52-A866-4C77-9A90-F570A7AA2C6B}"
}

Block "Configure winget argument completer" {
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
    iwr get.scoop.sh -OutFile $env:tmp\scoop-install.ps1
    & $env:tmp\scoop-install.ps1 -RunAsAdmin
} {
    Get-Command scoop -ErrorAction Ignore
}

Block "Update scoop" {
    scoop update
}

Block "Configure scoop nerd-fonts bucket" {
    scoop bucket add nerd-fonts
} {
    scoop bucket list | Select-String nerd-fonts
}

InstallFromScoopBlock CascadiaCode-NF

if (!(Configured $forTest)) {
    FirstRunBlock "Update PS help" {
        Update-Help -ErrorAction Ignore
    }
}
