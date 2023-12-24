##################################################
# QMK

function qmk-ps([Parameter(ValueFromRemainingArguments = $true)]$Rest) {
    C:\QMK_MSYS\shell_connector.cmd -c "qmk $Rest"
}

function flash() {
    qmk-ps compile -kb moonlander -km ben
    qmk-ps flash -kb moonlander -km ben
}

##################################################
# plex-playlist-liberator

function ppl([Parameter(Mandatory)][ValidateSet("Plex", "M3U")][string]$Master) {
    . "${env:ProgramFiles(x86)}\Plex\Plex Media Server\Plex Media Scanner.exe" --scan --refresh --force --section 1
    if ($Master -eq "Plex") {
        Copy-Item $env:OneDrive\Music\Playlists (tmpfor M3UBackup) -Recurse -Filter *.m3u
        & $git\plex-playlist-liberator\plex-playlist-liberator.ps1 -Export -Destination $env:OneDrive\Music\Playlists
    }
    else {
        & $git\plex-playlist-liberator\plex-playlist-liberator.ps1 -Export -Destination (tmpfor PlexBackup)
    }
    Set-Content $env:OneDrive\Music\Playlists\ToOrganize.m3u ""
    Write-Output "Scanning for orphans"
    $orphans = & $git\plex-playlist-liberator\plex-playlist-liberator.ps1 -ScanForOrphans -Source $env:OneDrive\Music\Playlists -MusicFolder $env:OneDrive\Music -Exclude *.mid, *.jpg, *.png, *.gif, *.txt, *.pdf, *.wpl, *.m3u, *.pdn, *.zip, *.no | select -Skip 1
    if ($orphans) {
        Write-Output "`tSaving to $env:OneDrive\Music\Playlists\ToOrganize.m3u"
        Set-Content $env:OneDrive\Music\Playlists\ToOrganize.m3u $orphans
    }
    & $git\plex-playlist-liberator\plex-playlist-liberator.ps1 -Sort -Source $env:OneDrive\Music\Playlists
    & $git\plex-playlist-liberator\plex-playlist-liberator.ps1 -Import -Source $env:OneDrive\Music\Playlists
}

##################################################
# Manual sync

function SyncKidsPmp() {
    $destinationDrive = Get-Volume -FileSystemLabel "AGP-A19" | select -exp DriveLetter
    if ($destinationDrive) {
        $destinationFolder = "${destinationDrive}:\Music"
        Remove-Item $destinationFolder\Korean -Recurse -ErrorAction Ignore
        Remove-Item $destinationFolder\Ringtones -Recurse -ErrorAction Ignore
        Remove-Item $destinationFolder\Playlists\*Best.m3u -ErrorAction Ignore
        Remove-Item $destinationFolder\Playlists\Ignore.m3u -ErrorAction Ignore
        Remove-Item $destinationFolder\Playlists\Korean.m3u -ErrorAction Ignore
        Remove-Item $destinationFolder\Playlists\ToOrganize.m3u -ErrorAction Ignore
        robocopy $env:OneDrive\Music $destinationFolder /XD Korean Ringtones /XF *Best.m3u Ignore.m3u Korean.m3u ToOrganize.m3u /Z /DCOPY:T /MIR /X /NDL

        Get-ChildItem $destinationFolder\Playlists *.m3u | % {
            (Get-Content $_ | ? { $_ -notlike "*Music\Korean*" }) -replace "$($env:OneDrive -replace "\\", "\\")\\Music", ".." | Set-Content $_
        }

        sleep -s 10 # some handle hasn't been released yet
        # 17 = ssfDRIVES (https://docs.microsoft.com/en-us/windows/win32/api/shldisp/ne-shldisp-shellspecialfolderconstants)
        (New-Object -ComObject Shell.Application).NameSpace(17).ParseName("${destinationDrive}:\").InvokeVerb("Eject")
    }
}

##################################################
# AWS

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

##################################################
# VeraCrypt

function New-VeraCryptContainer([Parameter(Mandatory)][string]$FilePath, [Parameter(Mandatory)][string]$Size) {
    $veraCryptFormatPath = "$OneDrive\Ben\Programs\VeraCrypt\Current\VeraCrypt Format-x64.exe"
    $filename = Split-Path $FilePath -Leaf
    . $veraCryptFormatPath /create $FilePath /password (SecureRead-Host "$filename Password") /pim (SecureRead-Host "$filename PIM") /encryption AES /hash sha512 /size $Size
}

##################################################
# Activation

function Activate-Office() {
    $officeKey = SecureRead-Host "Office key"
    cscript "$env:ProgramFiles\Microsoft Office\Office16\OSPP.VBS" /inpkey:$officeKey
    cscript "$env:ProgramFiles\Microsoft Office\Office16\OSPP.VBS" /act
    cscript "$env:ProgramFiles\Microsoft Office\Office16\OSPP.VBS" /dstatus
}
