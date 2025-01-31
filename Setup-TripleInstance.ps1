﻿$ErrorActionPreference = "Stop"

##
## Config data
##

$targetFolder = "e:\SolrCloud"
$installService = $true
$collectionPrefix = "search"
$solrPackage = "https://archive.apache.org/dist/lucene/solr/8.8.2/solr-8.8.2.zip" # For Sitecore v10.2
$zkPackage = "https://archive.apache.org/dist/zookeeper/zookeeper-3.6.2/apache-zookeeper-3.6.2-bin.tar.gz"; # for Solr 8.8.2

Invoke-Expression -Command ".\Setup-Configuration.ps1"

##
## Install process
##

Install-Module "7Zip4Powershell"
Import-Module ".\SolrCloud-Helpers" -DisableNameChecking -Force

# first clean up potential remnants of prior attempts
Invoke-Expression -Command ".\Remove-Services.ps1"
Remove-ZooKeeperInstances $zkData $solrData

$zkConnection = Make-ZookeeperConnection $zkData
$zkEnsemble = Make-ZooKeeperEnsemble $zkData

$solrHostNames = Make-SolrHostList $solrData
$solrHostEntry = Make-SolrHostEntry "127.0.0.1" $solrData

if($installService) {
	Install-NSSM -targetFolder $targetFolder
}

foreach ($instance in $zkData) {
	Install-ZooKeeperInstance -targetFolder $targetFolder -zkPackage $zkPackage -zkFolder $instance.Folder -zkInstanceId $instance.InstanceID -zkEnsemble $zkEnsemble -zkClientPort $instance.ClientPort -installService $installService
}

foreach ($instance in $zkData) {
	Start-ZooKeeperInstance -zkInstanceId $instance.InstanceID -installService $installService
}

foreach ($instance in $zkData) {
	Wait-ForZooKeeperInstance $instance.Host $instance.ClientPort
}

$certPwd = "A-Big-Secret"
$certFile = Generate-SolrCertificate -targetFolder $targetFolder -solrHostNames $solrHostNames -solrCertPassword $certPwd
Add-HostEntries -linesToAdd @("#", $solrHostEntry)

foreach ($instance in $solrData) {
	Install-SolrInstance -targetFolder $targetFolder -installService $installService -zkEnsembleConnectionString $zkConnection -solrFolderName $instance.Folder -solrHostname $instance.Host -solrClientPort $instance.ClientPort -certificateFile $certFile -certificatePassword $certPwd -solrPackage $solrPackage
}

#Configure-ZooKeeperForSsl -targetFolder $targetFolder -zkConnection $zkConnection -solrFolderName $solrData[0].Folder

foreach ($instance in $solrData) {
	Start-SolrInstance -solrClientPort $instance.ClientPort -installService $installService
}

foreach ($instance in $solrData) {
	Wait-ForSolrToStart $instance.Host $instance.ClientPort
}


# get first ZooKeeper and Solr instances
$firstZk = $zkData | Select-Object -first 1
$firstSolr = $solrData | Select-Object -first 1

$zkUrlForConfigurationUpload = $firstZk.Host + ":" + $firstZk.ClientPort
$solrFolder = $targetFolder + "\" + $firstSolr.Folder

Set-SolrConfigForSitecore $solrFolder $zkUrlForConfigurationUpload

# add firewall allow rules
Add-FirewallAllowRule $solrData[0].ClientPort $zkData[0].ClientPort
Add-FirewallAllowRule $solrData[1].ClientPort $zkData[1].ClientPort
Add-FirewallAllowRule $solrData[2].ClientPort $zkData[2].ClientPort

#Configure-SolrCollection -targetFolder $targetFolder -replicas $solrData.Length -solrHostname $solrData[0].Host -solrClientPort $solrData[0].ClientPort -collectionPrefix $collectionPrefix