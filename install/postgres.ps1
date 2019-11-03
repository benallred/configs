# Postgres
Write-Output "Download Postgres"
start https://www.enterprisedb.com/download-postgresql-binaries
$archivePath = (Read-Host "Path to zip").Trim('"')
$destinationFolder = "C:\BenLocal\programs\postgres"
Expand-Archive $archivePath $destinationFolder
[Environment]::SetEnvironmentVariable("Path", (Get-Item "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\").GetValue("Path", "", "DoNotExpandEnvironmentNames") + ";$destinationFolder\pgsql\bin", "Machine")

# psqlx
git clone https://github.com/pluralsight/psqlx.git $git\psqlx
if (!(Test-Path $profile) -or !(Select-String "psqlx.ps1" $profile)) {
    Add-Content -Path $profile -Value "`n"
    Add-Content -Path $profile -Value "`$psqlxRunner = `"psql`" # or `"docker`""
    Add-Content -Path $profile -Value ". $git\psqlx\psqlx.ps1"
}
