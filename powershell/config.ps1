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
        Write-Output "Updating from $((Get-Module $ModuleName).Version) to $((Find-Module $ModuleName).Version)"
        ReallyUpdate-Module $ModuleName
    }
}

Block "Update PSReadLine" {
    Write-Output "Updating from $((Get-Module PSReadLine).Version) to $((Find-Module PSReadLine).Version)"
    pwsh -NoProfile -c "Install-Module PSReadLine -Force"
    Remove-Module PSReadLine
    Import-Module PSReadLine
} {
    (Find-Module PSReadLine).Version -le (Get-Module PSReadLine).Version
}

InstallFromWingetBlock Microsoft.PowerShell

InstallFromWingetBlock Microsoft.WindowsTerminal

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

Block "Add timing to PowerShell profiles" {
    $profile | Get-Member -Type NoteProperty | % { @{ name = $_.Name; path = ($profile | select -exp $_.Name) } } | % {
        $profileContent = (Get-Content $_.path -Raw -ErrorAction Ignore) ?? ""
        $profileContent = ($profileContent -replace "(?ms)^\s*# profile timing start.+?# profile timing end\r?\n?", "").Trim()
        Set-Content $_.path @(
            ($_.name -eq "AllUsersAllHosts" `
                ? {
                # profile timing start
                $psLoadDurations = @()
                # profile timing end
            } `
                : $null)
            ($_.name -eq "CurrentUserCurrentHost" `
                ? {
                # profile timing start
                if ($psLoadDurations | ? { $_.name -eq 'CurrentUserCurrentHost' }) {
                    $psLoadDurations = @()
                }
                # profile timing end
            } `
                : $null)
            {
                # profile timing start
                $psLoadDurations += @{ name = "$_.name"; path = $PSCommandPath; stopwatch = [Diagnostics.Stopwatch]::StartNew() }
                # profile timing end
            }.ToString().Replace('$_.name', $_.name)
            $profileContent
            {
                # profile timing start
                $currentDuration = ($psLoadDurations | ? { $_.name -eq '$name_closed' })
                $currentDuration.stopwatch.Stop()
                $currentDuration.elapsed = $currentDuration.stopwatch.Elapsed
                # profile timing end
            }.ToString().Replace('$name_closed', $_.name)
            ($_.name -eq "CurrentUserCurrentHost" `
                ? {
                # profile timing start
                foreach ($psLoadDuration in $psLoadDurations) {
                    if ($psLoadDuration.name -eq "CurrentUserCurrentHost") {
                        $cuchProfile = $psLoadDuration
                    }
                    elseif ($cuchProfile) {
                        $cuchProfile.elapsed -= $psLoadDuration.stopwatch.Elapsed
                    }
                }
                $psLoadDurations += @{ name = "Total"; elapsed = [TimeSpan]::FromMilliseconds(($psLoadDurations | % { $_.elapsed.TotalMilliseconds } | measure -Sum).Sum) }
                ($psLoadDurations `
                | select name, path, stopwatch, elapsed `
                | Format-Table name, @{ Label = "elapsed"; Expression = { "$([int]$_.elapsed.TotalMilliseconds)ms" }; Alignment = "Right" } -HideTableHeaders `
                | Out-String
                ).Trim()
                # profile timing end
            } `
                : $null)
        )
    }
}

if (!(Configured $forTest)) {
    FirstRunBlock "Update PS help" {
        Update-Help -ErrorAction Ignore
    }
}
