$ErrorActionPreference = "Stop"

$targetFolder = "e:\SolrCloud"

Install-Module "7Zip4Powershell"
Import-Module ".\SolrCloud-Helpers" -DisableNameChecking

Install-OpenJDK -targetFolder $targetFolder

Write-Host "You should refresh other PowerShell/CMD windows now..."