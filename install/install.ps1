iwr -useb get.scoop.sh | iex
scoop bucket add java

scoop install adopt8-hotspot -a 32bit # Java 1.8 JDK; Metals for VS Code does not work with 64-bit
scoop install sbt scala # Scala
