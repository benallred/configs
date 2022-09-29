$owner = Read-Host Owner
$repo = $pwd | Split-Path -Leaf
$workRepo = $owner -ne "benallred"
gh repo create "$owner/$repo" ($workRepo ? "--private" : "--public") --source . --description (Read-Host Description)

gh repo edit --enable-merge-commit=false
gh repo edit --enable-squash-merge=false
gh repo edit --delete-branch-on-merge

Write-Host "When ready run ``git pushu``" -ForegroundColor Yellow

if ($workRepo) {
    Write-Output "$($PSStyle.Foreground.BrightYellow)Add team: $($PSStyle.Reset)https://github.com/$owner/$repo/settings/access"
    Write-Output "$($PSStyle.Foreground.BrightYellow)Require linear history: $($PSStyle.Reset)https://github.com/$owner/$repo/settings/branch_protection_rules/new"
}
