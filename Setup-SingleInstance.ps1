Param(
	[Parameter(Mandatory=$true)][Int32]$instance
)

$ErrorActionPreference = "Stop"

##
## Config data
##

# Getting an error here? Check the readme file!
$zkData = Get-Content .\zookeeper_config.json | ConvertFrom-Json
$solrData = Get-Content .\solr_config.json | ConvertFrom-Json

$targetFolder = "e:\SolrCloud"
$installService = $true
$collectionPrefix = "search"
$solrPackage = "https://archive.apache.org/dist/lucene/solr/8.8.2/solr-8.8.2.zip" # For Sitecore v10.2
$zkPackage = "https://archive.apache.org/dist/zookeeper/zookeeper-3.6.2/apache-zookeeper-3.6.2-bin.tar.gz"; # for Solr 8.8.2

$zkInstance = $zkData[$instance-1]
$solrInstance = $solrData[$instance-1]

##
## Install process
##

Install-Module "7Zip4Powershell"
Import-Module ".\SolrCloud-Helpers" -DisableNameChecking

# get NSSM present as it's used in Remove-ZooKeeperInstances
if($installService)
{
	Install-NSSM -targetFolder $targetFolder
}

# first clean up potential remnants of prior attempts
Import-Module ".\Remove-Services.ps1" -Force
Remove-ZooKeeperInstances $zkData $solrData

$zkConnection = Make-ZookeeperConnection $zkData
$zkEnsemble = Make-ZooKeeperEnsemble $zkData

$solrHostNames = Make-SolrHostList $solrData
$solrHostEntry = Make-SolrHostEntry "127.0.0.1" $solrData

Add-FirewallAllowRule $solrInstance.ClientPort $zkInstance.ClientPort $zkInstance.PeerPort $zkInstance.ElectionPort

Install-ZooKeeperInstance -targetFolder $targetFolder -zkPackage $zkPackage -zkFolder $zkInstance.Folder -zkInstanceId $zkInstance.InstanceID -zkEnsemble $zkEnsemble -zkClientPort $zkInstance.ClientPort -installService $installService

Start-ZooKeeperInstance -zkInstanceId $zkInstance.InstanceID -installService $installService

Wait-ForZooKeeperInstance $zkInstance.Host $zkInstance.ClientPort

$certPwd = "A-Big-Secret"
$certFile = Generate-SolrCertificate -targetFolder $targetFolder -solrHostNames $solrHostNames -solrCertPassword $certPwd
#Add-HostEntries -linesToAdd @("#", $solrHostEntry)

Install-SolrInstance -targetFolder $targetFolder -installService $installService -zkEnsembleConnectionString $zkConnection -solrFolderName $solrInstance.Folder -solrHostname $solrInstance.Host -solrClientPort $solrInstance.ClientPort -certificateFile $certFile -certificatePassword $certPwd -solrPackage $solrPackage

#Configure-ZooKeeperForSsl -targetFolder $targetFolder -zkConnection $zkConnection -solrFolderName $solrInstance.Folder

Start-SolrInstance -solrClientPort $solrInstance.ClientPort -installService $installService

Wait-ForSolrToStart $solrInstance.Host $solrInstance.ClientPort

$zkUrlForConfigurationUpload = $zkInstance.Host + ":" + $zkInstance.ClientPort
$solrFolder = $targetFolder + "\" + $solrInstance.Folder

Set-SolrConfigForSitecore $solrFolder $zkUrlForConfigurationUpload

#Configure-SolrCollection -targetFolder $targetFolder -replicas $solrData.Length -solrHostname $solrData[0].Host -solrClientPort $solrData[0].ClientPort -collectionPrefix $collectionPrefix