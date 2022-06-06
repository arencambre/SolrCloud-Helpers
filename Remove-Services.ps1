<#
.Description
Remove-ZooKeeperInstances removes prior services created by NSSM. This is to 
clean up prior attempts before beginning a new setup.
#>
function Remove-ZooKeeperInstances {
    param(
        $zkData,
        $solrData
    )

    # remove ZooKeeper instances
    foreach($entry in $zkData) {
        $instanceName = "ZooKeeper-" + $entry.InstanceID # create instance name
        if($installService)
        {
            & "$targetFolder\nssm\nssm.exe" stop $instanceName # stop service
            & "$targetFolder\nssm\nssm.exe" remove $instanceName confirm # remove service
        }
        Write-Host "Removing $instanceName files"
        $path = $targetFolder + "\" + $entry.Folder + "\"
        Remove-Item $path -Recurse -ErrorAction Ignore
    }

    # remove Solr instances
    foreach($entry in $solrData) {
        $instanceName = "Solr-" + $entry.ClientPort # create instance name

        if($installService)
        {
            & "$targetFolder\nssm\nssm.exe" stop $instanceName # stop service
            & "$targetFolder\nssm\nssm.exe" remove $instanceName confirm # remove service
        }
        Write-Host "Removing $instanceName files"
        $path = $targetFolder + "\" + $entry.Folder
        Remove-Item $path -Recurse -ErrorAction Ignore
    }

    Remove-FirewallAllowRules
}