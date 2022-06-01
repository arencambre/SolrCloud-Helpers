$ErrorActionPreference = "Stop"

##
## Config data
##

$targetFolder = "e:\SolrCloud"
$installService = $false
$collectionPrefix = "search"
$solrPackage = "https://archive.apache.org/dist/lucene/solr/7.2.1/solr-7.2.1.zip" # For Sitecore v9.1
#$solrPackage = "https://archive.apache.org/dist/lucene/solr/7.5.0/solr-7.5.0.zip" # For Sitecore v9.2
#$solrPackage = "https://archive.apache.org/dist/lucene/solr/8.1.1/solr-8.1.1.zip" # For Sitecore V9.3
#$solrPackage = "https://archive.apache.org/dist/lucene/solr/8.4.0/solr-8.4.0.zip" # For Sitecore v10.1
$solrPackage = "https://archive.apache.org/dist/lucene/solr/8.8.2/solr-8.8.2.zip" # For Sitecore v10.2
$zkPackage = "https://archive.apache.org/dist/zookeeper/zookeeper-3.6.2/apache-zookeeper-3.6.2.tar.gz"; # for Solr 8.8.2 (Sitecore 10.2)

$zkData = @(
	@{Host = "localhost"; Folder="zk"; InstanceID=1; ClientPort = 2971; EnsemblePorts="2981:2991"}
)

$solrData = @(
	@{Host="solr"; Folder="SOLR"; ClientPort=9999}
)

##
## Install process
##

Install-Module "7Zip4Powershell"
Import-Module ".\SolrCloud-Helpers" -DisableNameChecking

$zkConnection = Make-ZookeeperConnection $zkData
$zkEnsemble = Make-ZooKeeperEnsemble $zkData

$solrHostNames = Make-SolrHostList $solrData
$solrHostEntry = Make-SolrHostEntry "127.0.0.1" $solrData

if($installService)
{
	Install-NSSM -targetFolder $targetFolder
}

foreach($instance in $zkData)
{
	Install-ZooKeeperInstance -targetFolder $targetFolder -zkPackage $zkPackage -zkFolder $instance.Folder -zkInstanceId $instance.InstanceID -zkEnsemble $zkEnsemble -zkClientPort $instance.ClientPort -installService $installService
}

foreach($instance in $zkData)
{
	Start-ZooKeeperInstance -zkInstanceId $instance.InstanceID -installService $installService
}

foreach($instance in $zkData)
{
	Wait-ForZooKeeperInstance $instance.Host $instance.ClientPort
}

$certPwd = "A-Big-Secret"
$certFile = Generate-SolrCertificate -targetFolder $targetFolder -solrHostNames $solrHostNames -solrCertPassword $certPwd
Add-HostEntries -linesToAdd @("#", $solrHostEntry)

foreach($instance in $solrData)
{
	Install-SolrInstance -targetFolder $targetFolder -installService $installService -zkEnsembleConnectionString $zkConnection -solrFolderName $instance.Folder -solrHostname $instance.Host -solrClientPort $instance.ClientPort -certificateFile $certFile -certificatePassword $certPwd -solrPackage $solrPackage
}

Configure-ZooKeeperForSsl -targetFolder $targetFolder -zkConnection $zkConnection -solrFolderName $solrData[0].Folder

foreach($instance in $solrData)
{
	Start-SolrInstance -solrClientPort $instance.ClientPort -installService $installService
}

foreach($instance in $solrData)
{
	Wait-ForSolrToStart $instance.Host $instance.ClientPort
}

Configure-SolrCollection -targetFolder $targetFolder -replicas $solrData.Length -solrHostname $solrData[0].Host -solrClientPort $solrData[0].ClientPort -collectionPrefix $collectionPrefix