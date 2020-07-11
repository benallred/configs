ScheduledTaskBlock "Scheduled Tasks: Home: Daily" "$PSScriptRoot\daily.ps1" "Daily (Home)"
ScheduledTaskBlock "Scheduled Tasks: Home: Monthly" "$PSScriptRoot\monthly.ps1" "Monthly (Home)"

ScheduledTaskBlock "Scheduled Tasks: Home: Speedtest 1" "$PSScriptRoot\speedtest.ps1" "Speedtest 1" 08:00
ScheduledTaskBlock "Scheduled Tasks: Home: Speedtest 2" "$PSScriptRoot\speedtest.ps1" "Speedtest 2" 14:00
ScheduledTaskBlock "Scheduled Tasks: Home: Speedtest 3" "$PSScriptRoot\speedtest.ps1" "Speedtest 3" 00:00
