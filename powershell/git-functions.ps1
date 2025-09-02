function Get-RepoRoot() {
    git rev-parse --show-toplevel
}

function GitAudit([switch]$ReturnSuccess) {
    $script:GitAudit_success = $true
    function CheckDir($dir) {
        if (Test-Path (Join-Path $dir .git)) {
            pushd $dir
            $unsynced = git unsynced
            $status = git status --porcelain
            if ($unsynced -or $status) {
                $script:GitAudit_success = $false
                Write-Host ('*' * 100)
                Write-Host $dir -ForegroundColor Red
                git unsynced --color=always | Write-Host
                git status --porcelain | Write-Host
            }
            popd
        }
        elseif (Test-Path $dir -PathType Container) {
            $script:GitAudit_success = $false
            Write-Host ('*' * 100)
            Write-Host $dir -ForegroundColor Red
            Write-Host "`tNot in source control"
        }
    }
    (Get-ChildItem $git) +
    (Get-ChildItem C:\Work -ErrorAction Ignore | Get-ChildItem) |
        % { CheckDir $_.FullName }
    if ($ReturnSuccess) {
        return $script:GitAudit_success
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

