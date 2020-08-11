$now = (Get-Date -Format o) -replace ":", "_"

function BackupRegistryRootKey($rootkey) {
    Write-Output "Backing up $rootkey"
    reg export $rootkey C:\BenLocal\backup\reg-$now-$rootkey.reg
}

("HKCR", "HKCU", "HKLM", "HKU", "HKCC") | % { BackupRegistryRootKey $_ }
