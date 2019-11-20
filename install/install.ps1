Block "Install Edge (Dev)" {
    iwr "https://go.microsoft.com/fwlink/?linkid=2069324&Channel=Dev&language=en&Consent=1" -OutFile $env:tmp\MicrosoftEdgeSetupDev.exe
    start $env:tmp\MicrosoftEdgeSetupDev.exe
} {
    (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*).DisplayName -eq "Microsoft Edge Dev"
}

Block "Configure scoop extras bucket" {
    scoop bucket add extras
}

Block "Install Sysinternals" {
    scoop install sysinternals
}

Block "Install dotnet" {
    scoop install dotnet-sdk
}

Block "Install Java and Scala" {
    scoop bucket add java
    scoop install adopt8-hotspot -a 32bit # Java 1.8 JDK; Metals for VS Code does not work with 64-bit
    scoop install sbt scala # Scala
}

Block "Install/clone git projects" {
    git clone https://github.com/benallred/YouTubeToPlex.git $git\YouTubeToPlex
}
