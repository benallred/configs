$checklist = @(
    @{
        description = "Make sure everything in `$git and C:\Work is pushed"
        action      = {
            GitAudit -ReturnSuccess
        }
    }
    (Configured $forHome) ? @{
        description = "Back up to external drives"
        action      = {
            try {
                . $PSScriptRoot\scheduled-tasks\home\daily.ps1 | Write-Host
                Remove-Item C:\BenLocal\.ps.lastRunTime.monthly.txt
                . $PSScriptRoot\scheduled-tasks\home\monthly.ps1 | Write-Host
                return $true
            }
            catch {
                Write-Host $_ -ForegroundColor Red
                return $false
            }
        }
    } : $null
    @{ description = "Check open browser tabs"; manual = $true }
    @{ description = "Check unsaved docs in VS Code"; manual = $true }
    @{ description = "Make sure VS Code settings are synced"; manual = $true }
    @{ description = "Make sure OneDrive is synced"; manual = $true }
    @{ description = "Make sure OneNote is synced"; manual = $true }
    @{ description = "Quick review of C:\BenLocal"; manual = $true }
) | ? { $null -ne $_ }

function WriteChecklist() {
    Write-Host ('*' * 100) -ForegroundColor DarkYellow
    Write-Host "Pre-wipe checklist" -ForegroundColor DarkYellow
    $checklist | % {
        $icon = $null -eq $_.success ? "`u{f630}" : $_.success ? "`u{f42e}" : "`u{f467}"
        $color = $null -eq $_.success ? "Yellow" : $_.success ? "Green" : "Red"
        Write-Host "`t$icon " -NoNewline -ForegroundColor $color
        if ($_.manual) {
            Write-Host "(Manual) " -NoNewline -ForegroundColor Yellow
        }
        Write-Host $_.description
    }
}

WriteChecklist
$checklist | % {
    if (!$_.manual) {
        Write-Host ('*' * 100) -ForegroundColor DarkYellow
        Write-Host $_.description -ForegroundColor DarkYellow
        $_.success = Invoke-Command $_.action
    }
}
WriteChecklist
