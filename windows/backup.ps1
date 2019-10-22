$now = Get-TimestampForFileName
mkdir C:\BenLocal\backup -ErrorAction Ignore

function BackupRegistryRootKey($rootkey) {
	Write-Output "Backing up $rootkey"
	reg export $rootkey C:\BenLocal\backup\reg-$now-$rootkey.reg
}

("HKCR", "HKCU", "HKLM", "HKU", "HKCC") | % { BackupRegistryRootKey $_ }
