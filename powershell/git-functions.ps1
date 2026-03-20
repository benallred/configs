function Get-RepoRoot() {
    git rev-parse --show-toplevel
}

function Get-GitHubDefaultBranch() {
    gh repo view --json defaultBranchRef --jq ".defaultBranchRef.name"
}

function Test-GitRepoClean([string]$Dir = (Get-Location).Path) {
    if (!(Test-Path (Join-Path $Dir .git))) {
        if (Test-Path $Dir -PathType Container) {
            Write-Host "Not in source control"
        }
        else {
            Write-Host "Not a folder"
        }
        return $false
    }

    pushd $Dir
    $unsynced = git unsynced
    $status = git status --porcelain
    $stashes = git stash list
    popd

    if ($unsynced -or $status -or $stashes) {
        if ($unsynced) { git -C $Dir unsynced --color=always | Write-Host }
        if ($status) { git -C $Dir -c color.status=always status --short | Write-Host }
        if ($stashes) { $stashes | Write-Host }
        return $false
    }

    return $true
}

function GitAudit([switch]$ReturnSuccess) {
    $results = (Get-ChildItem $git) +
    (Get-ChildItem C:\Work\repos -ErrorAction Ignore) |
        % {
            $dir = $_.FullName
            Write-Host ('*' * 100)
            Write-Host $dir -ForegroundColor Red
            $clean = Test-GitRepoClean $dir
            if ($clean) {
                Write-Host "`e[2A`e[J" -NoNewline
            }
            $clean
        } |
        ? { !$_ }
    if ($ReturnSuccess) {
        return !$results
    }
}

function togh([Parameter(Mandatory)][string]$FilePath, [int]$BeginLine, [int]$EndLine) {
    pushd (Split-Path $FilePath)
    $remote = (git config remote.origin.url) -replace "\.git", ""
    $permalinkCommit = git rev-parse --short head
    $relativePath = git ls-files --full-name $FilePath
    popd

    $url = "$remote/blob/$permalinkCommit/$relativePath" `
        + ($BeginLine -gt 0 ? "#L$BeginLine" + ($EndLine -gt 0 ? "-L$EndLine" : "") : "")
    $url = $url -replace " ", "%20"

    $url | clip2
}

$gwtArgumentCompleter = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $worktrees = git worktree list --porcelain 2>$null
    $worktreePaths = $worktrees | ? { $_ -match '^worktree (.+)$' } | % {
        $Matches[1]
    }
    $worktreePaths |
        % { $_ -replace '/', '\' } |
        ? { $_ -ne (pwd) -and $_ -like "*$wordToComplete*" }
}

Register-ArgumentCompleter -CommandName gwt -ParameterName Path -ScriptBlock $gwtArgumentCompleter

function gwt([string]$Path) {
    if (!$Path) {
        git worktree list
        return
    }
    pushd $Path
}
