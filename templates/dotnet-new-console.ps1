$solutionName = Read-Host "Solution name"

mkdir $solutionName
cd $solutionName
git init
git config --local user.email (Read-Host "git user.email")

dotnet new sln

dotnet new console -o $solutionName
dotnet sln add $solutionName

dotnet new xunit -o "$solutionName.Tests"
dotnet sln add "$solutionName.Tests"
dotnet add "$solutionName.Tests" reference $solutionName

dotnet new gitignore
Copy-Item $PSScriptRoot\.editorconfig .\
Copy-Item $PSScriptRoot\..\license.md .\
Set-Content .\readme.md "# $solutionName

## Requirements

[.NET Core 5](https://dotnet.microsoft.com/download)"

git add .
git c "dotnet new"

function TreatWarningsAsErrors($projectName) {
    $csproj = [xml](Get-Content .\$projectName\$projectName.csproj)
    $treatWarningsAsErrors = $csproj.CreateElement("TreatWarningsAsErrors")
    $treatWarningsAsErrors.InnerText = "true"
    $csproj.Project.PropertyGroup.AppendChild($treatWarningsAsErrors)
    $csproj.Save("$pwd\$projectName\$projectName.csproj")
}

TreatWarningsAsErrors $solutionName
TreatWarningsAsErrors "$solutionName.Tests"

git add .
git c "TreatWarningsAsErrors"

dotnet add $solutionName package System.CommandLine --prerelease
Add-Content .\readme.md "
## Usage

``dotnet run --project .\$solutionName\ -- --help``"
git add .
git c "NuGet: System.CommandLine"

dotnet add "$solutionName.Tests" package Shouldly
git add .
git c "NuGet: Shouldly"
