function WindowsFeatureBlock([string]$Comment, [string]$FeatureName) {
    Block "Windows Features > $Comment = On" {
        Enable-WindowsOptionalFeature -Online -FeatureName $FeatureName -All -NoRestart
    } {
        (Get-WindowsOptionalFeature -Online -FeatureName $FeatureName).State -eq "Enabled"
    } -RequiresReboot
}

WindowsFeatureBlock ".NET Framework 3.5 (includes .NET 2.0 and 3.0)" NetFx3
WindowsFeatureBlock "Internet Information Services > Web Management Tools > IIS Management Console" IIS-ManagementConsole
WindowsFeatureBlock "Internet Information Services > World Wide Web Services > Application Development Features > ASP.NET 4.x" IIS-ASPNET45
WindowsFeatureBlock "Hyper-V" Microsoft-Hyper-V
