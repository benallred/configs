iwr "https://go.microsoft.com/fwlink/?linkid=2069324&Channel=Dev&language=en&Consent=1" -OutFile $env:tmp\MicrosoftEdgeSetupDev.exe
start $env:tmp\MicrosoftEdgeSetupDev.exe

scoop bucket add extras
scoop bucket add java

scoop install sysinternals

scoop install adopt8-hotspot -a 32bit # Java 1.8 JDK; Metals for VS Code does not work with 64-bit
scoop install sbt scala # Scala

git clone https://github.com/benallred/YouTubeToPlex.git $git\YouTubeToPlex
