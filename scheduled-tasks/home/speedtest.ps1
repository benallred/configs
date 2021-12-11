Import-Module BurntToast

$sleepSeconds = Get-Random -Maximum 3600
echo "Now: $(Get-Date -Format "HH:mm")"
echo "Waiting until $((Get-Date).AddSeconds($sleepSeconds).ToString("HH:mm")) to run speedtest"
sleep -Seconds ($sleepSeconds)
$json = ConvertFrom-Json (speedtest -f json)
$megaBitsPerSecond = ($json.download.bytes / $json.download.elapsed * 1000 / 125000)
Add-Content $OneDrive\.speedtest.log $megaBitsPerSecond
$measurements = Get-Content $OneDrive\.speedtest.log
$megaBitsPerSecond_AvgDay = $measurements | select -Last 3 | Measure-Object -Average | select -ExpandProperty Average
$megaBitsPerSecond_AvgWeek = $measurements | select -Last 21 | Measure-Object -Average | select -ExpandProperty Average
$megaBitsPerSecond_AvgAll = $measurements | Measure-Object -Average | select -ExpandProperty Average
New-BurntToastNotification -Header (New-BTHeader -Id ec9f5700-36d1-4f18-bb09-2808e35ff33a -Title "Speedtest (Mbps)") -Text "Last: $($megaBitsPerSecond.ToString("N0")); Week: $($megaBitsPerSecond_AvgWeek.ToString("N0")); All: $($megaBitsPerSecond_AvgAll.ToString("N0"))" -Button (New-BTButton -Dismiss)

if ($megaBitsPerSecond_AvgDay -lt 100) {
    New-BurntToastNotification -Header (New-BTHeader -Id ec9f5700-36d1-4f18-bb09-2808e35ff33a -Title "Speedtest (Mbps)") -Text "Recommend rebooting router; Day: $($megaBitsPerSecond_AvgDay.ToString("N0"))" -Button (New-BTButton -Content "Reboot router" -Arguments http://192.168.0.1/RouterStatus.htm)
}
