Get-ChildItem "$transcriptDir\*.log" | ? { $_.LastWriteTime -lt (Get-Date).AddMonths(-1) } | rm -ErrorAction SilentlyContinue
Get-ChildItem "$transcriptDir\*.log" | ? { !(sls -Path $_ -Pattern "Command start time:" -SimpleMatch -Quiet) } | rm -ErrorAction SilentlyContinue
