function Update-AwsAccessKey() {
    Write-Output "Creating new access key"
    $newKey = aws iam create-access-key | ConvertFrom-Json | select -exp AccessKey
    aws configure set aws_access_key_id $newKey.AccessKeyId
    sleep -s 1 # the second set below sometimes fails because the first one still has the file locked
    aws configure set aws_secret_access_key $newKey.SecretAccessKey
    Write-Output "`t$($newKey.AccessKeyId.Substring($newKey.AccessKeyId.Length - 3, 3))"

    Write-Output "Waiting 10 seconds because AWS doesn't seem to acknowledge the new key right away"
    sleep -s 10

    Write-Output "Getting all keys"
    $allKeys = aws iam list-access-keys | ConvertFrom-Json | select -exp AccessKeyMetadata
    if ($allKeys.Length -le 1) {
        Write-Error "Expected more than one key"
        return
    }
    elseif ($allKeys.Length -gt 2) {
        Write-Output "`tFound $($allKeys.Length) keys"
    }

    Write-Output "Deleting oldest key"
    $oldKey = $allKeys | sort { $_.CreateDate } | select -First 1 | select -exp AccessKeyId
    Write-Output "`t$($oldKey.Substring($oldKey.Length - 3, 3))"
    aws iam delete-access-key --access-key-id $oldKey
}

function Get-AwsSsoAccounts {
    $token = Get-ChildItem "$env:UserProfile\.aws\sso\cache" -Filter "*.json" -ErrorAction SilentlyContinue |
        ForEach-Object { $_ | Get-Content -Raw | ConvertFrom-Json } |
        Where-Object { $_.accessToken -and (Get-Date $_.expiresAt) -gt (Get-Date) } |
        Sort-Object { Get-Date $_.expiresAt } -Descending |
        Select-Object -First 1 -ExpandProperty accessToken

    if (!$token) {
        Write-Error "No valid SSO token found. Run 'aws sso login --profile <profile>' first."
        return
    }

    $accounts = aws sso list-accounts --access-token $token --output json |
        ConvertFrom-Json |
        Select-Object -ExpandProperty accountList |
        Sort-Object accountName

    $total = $accounts.Count
    $results = for ($i = 0; $i -lt $total; $i++) {
        $account = $accounts[$i]
        Write-Progress -Activity "Fetching roles" -Status $account.accountName -PercentComplete (($i / $total) * 100)

        $roles = aws sso list-account-roles --access-token $token --account-id $account.accountId --output json |
            ConvertFrom-Json |
            Select-Object -ExpandProperty roleList |
            Select-Object -ExpandProperty roleName

        foreach ($role in $roles) {
            $accountSlug = ($account.accountName -replace '\s+', '-' -replace '[^a-zA-Z0-9\-]', '').ToLower()
            [PSCustomObject]@{
                AccountName = $account.accountName
                ProfileName = "$accountSlug-$role"
                AccountId   = $account.accountId
                Role        = $role
            }
        }
    }
    Write-Progress -Activity "Fetching roles" -Completed

    $results | Sort-Object ProfileName, Role | Format-Table -AutoSize
}

function ap([ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
            $configFile = if ($env:AWS_CONFIG_FILE) { $env:AWS_CONFIG_FILE } else { "$env:USERPROFILE\.aws\config" }
            (Select-String '^\[profile (.+)\]$' $configFile).Matches.Groups |
                Where-Object Name -EQ 1 |
                Select-Object -exp Value |
                Where-Object { $_ -like "*$wordToComplete*" }
        })]$AwsProfile) {
    $env:AWS_PROFILE = $AwsProfile
    if ($AwsProfile -and !(aws sts get-caller-identity)) {
        aws sso login
    }
}
