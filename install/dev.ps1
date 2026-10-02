InstallFromWingetBlock Microsoft.VisualStudioCode {
    Write-ManualStep "Turn on Settings Sync"
    Write-ManualStep "`tReplace Local"
    Write-ManualStep "Watch log with ctrl+shift+u"
    Write-ManualStep "Show synced data"
    Write-ManualStep "`tUpdate name of synced machine"
    code
}

Block "Install AutoHotkey" {
    winget install AutoHotkey.AutoHotkey --override "/S /IsHostApp" --version 1.1.37.02
}

if (Configured $forHome, $forWork, $forTest) {
    InstallFromWingetBlock Microsoft.DotNet.SDK.10 {
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

    InstallFromWingetBlock pnpm.pnpm

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

    Block "Install Python" {
        $latestPython = winget search Python | sls "Python\.Python\.\d+\.(\d+)" | % { @{ id = $_.Matches.Value; sort = [int]$_.Matches.Groups[1].Value } } | sort sort -Descending | select -First 1 -ExpandProperty id
        InstallFromWingetBlock $latestPython
        # Claude sometimes invokes python3
        $pythonDir = Split-Path (Get-Command python).Source
        Copy-Item "$pythonDir\python.exe" "$pythonDir\python3.exe"
    }

    Block "Install Claude Code" {
        & ([scriptblock]::Create((irm https://claude.ai/install.ps1))) stable
        AddTo-Path $env:UserProfile\.local\bin
        Copy-Item2 $PSScriptRoot\..\agents\.claude\settings.json $env:UserProfile\.claude\
        Add-Content -Path $env:UserProfile\.claude\CLAUDE.md -Value "@$(($git -replace '\\', '/'))/configs/agents/AGENTS.md"
    } {
        Get-Command claude -ErrorAction Ignore
    }

    Block "Install Codex" {
        $env:CODEX_NON_INTERACTIVE = 1
        irm https://chatgpt.com/codex/install.ps1 | iex

        Write-ManualStep "/permissions = Approve for me"
        codex

        Add-Content -Path $env:UserProfile\.codex\AGENTS.md -Value "Before responding to the first user message or taking any action, read these files in full and apply their instructions:"
        Add-Content -Path $env:UserProfile\.codex\AGENTS.md -Value "@$(($git -replace '\\', '/'))/configs/agents/AGENTS.md"
    } {
        Get-Command codex -ErrorAction Ignore
    } {
        $true
    } {
        $env:CODEX_NON_INTERACTIVE = 1
        irm https://chatgpt.com/codex/install.ps1 | iex
    }

    InstallFromGitHubBlock benallred claude.ben

    Block "Configure personal Claude Code plugin" {
        claude plugin marketplace add ((Resolve-Path $git\claude.ben -Relative) -replace '\\', '/')
        claude plugin install ben@ben-marketplace
    } {
        claude plugin marketplace list | sls ben-marketplace
    }
}
