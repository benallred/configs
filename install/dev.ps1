InstallFromWingetBlock Microsoft.VisualStudioCode {
    Write-ManualStep "Turn on Settings Sync"
    Write-ManualStep "`tReplace Local"
    Write-ManualStep "Watch log with ctrl+shift+u"
    Write-ManualStep "Show synced data"
    Write-ManualStep "`tUpdate name of synced machine"
    code
}

InstallFromWingetBlock Lexikos.AutoHotkey "/S /IsHostApp"

if (Configured $forHome, $forWork, $forTest) {
    InstallFromWingetBlock Microsoft.DotNet.SDK.8 {
        Set-EnvironmentVariable MSBUILDTERMINALLOGGER auto
        Add-Content -Path $profile {
            Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
                param($wordToComplete, $commandAst, $cursorPosition)
                dotnet complete --position $cursorPosition $commandAst | ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
                }
            }
        }
    }

    Block "Add nuget.org source" {
        dotnet nuget add source https://api.nuget.org/v3/index.json -n nuget.org
    } {
        dotnet nuget list source | sls nuget.org
    }

    InstallFromScoopBlock nvm {
        nvm install latest
        nvm use latest
    }

    InstallFromWingetBlock GitHub.cli {
        gh config set editor (git config core.editor)
        Add-Content -Path $profile {
            (gh completion -s powershell) -join "`n" | iex
        }
        if (!(Configured $forTest)) {
            $ghPat_Cli = SecureRead-Host "GH PAT (CLI)"
            $ghPat_Cli | gh auth login --with-token
        }
    }

    Block "Install Claude Code" {
        irm https://claude.ai/install.ps1 | iex
        Copy-Item2 $PSScriptRoot\..\agents\.claude\settings.json $env:UserProfile\.claude\
        Add-Content -Path $env:UserProfile\.claude\CLAUDE.md -Value "IMPORTANT: The files loaded below using @ syntax contain critical agent definitions and instructions that you MUST read and follow at the start of EVERY conversation before proceeding with any task. These instructions OVERRIDE default behavior."
        Add-Content -Path $env:UserProfile\.claude\CLAUDE.md -Value "@$git\configs\agents\AGENTS.md"
    } {
        Get-Command claude
    }
}
