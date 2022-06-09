$ErrorActionPreference = "Stop"

$targetFolder = "e:\SolrCloud"
$javaRelease = "https://github.com/ojdkbuild/ojdkbuild/releases/download/java-1.8.0-openjdk-1.8.0.332-1.b09/java-1.8.0-openjdk-jre-1.8.0.332-1.b09.ojdkbuild.windows.x86_64.zip"

Install-Module "7Zip4Powershell"
Import-Module ".\SolrCloud-Helpers" -DisableNameChecking

Install-OpenJDK -targetFolder $targetFolder -javaRelease $javaRelease

Write-Host "You should refresh other PowerShell/CMD windows now..."