Write-SeparatorAndHeader "Update My Board Game Stats"

$backupFolder = "$env:UserProfile\OneDrive\Android\Backups\BG Stats"
$repoFolder = "$git\my-bg-stats-private-data"
$fileName = "BGStatsExport.json"

$exports = Get-ChildItem $backupFolder -File | ? { $_.Name -match "^BGStatsExport( \(\d+\))?\.json$" } | Sort-Object LastWriteTime -Descending
if (!$exports) {
    throw "No $fileName files found in $backupFolder"
}

function IsValidExport([System.IO.FileInfo]$File) {
    if (!$File.Length) {
        Write-Warning "Skipping empty export $($File.Name)"
        return $false
    }
    try {
        Get-Content $File.FullName -Raw | ConvertFrom-Json -AsHashtable | Out-Null
    }
    catch {
        Write-Warning "Skipping unparsable export $($File.Name): $($_.Exception.Message)"
        return $false
    }
    return $true
}

# newest export that isn't empty or truncated - an unusable export would otherwise overwrite good data in the repo
$latest = $exports | ? { IsValidExport $_ } | Select-Object -First 1
if (!$latest) {
    throw "No valid $fileName files found in $backupFolder"
}

Write-Output "Latest export is $($latest.Name) ($($latest.LastWriteTime))"

StopOnError { git -C $repoFolder pull }

Copy-Item $latest.FullName $repoFolder\$fileName -Force

$status = git -C $repoFolder status --porcelain -- $fileName
if ($LastExitCode) {
    throw "Received exit code $LastExitCode"
}

if ($status) {
    StopOnError { git -C $repoFolder add -- $fileName }
    StopOnError { git -C $repoFolder commit -m "update $fileName" }
    StopOnError { git -C $repoFolder push }
}
else {
    Write-Output "$fileName is unchanged"
}

$exports | ? { $_.FullName -ne $latest.FullName } | Remove-Item
if ($latest.Name -ne $fileName) {
    Rename-Item $latest.FullName $fileName
}
