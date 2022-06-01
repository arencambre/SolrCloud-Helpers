<#
.Description
Remove-ZooKeeperInstances removes prior services created by NSSM. This is to 
clean up prior attempts before beginning a new setup.
#>
function Remove-ZooKeeperInstances {
    # stop services
    & "$targetFolder\nssm\nssm.exe" stop ZooKeeper-1
    & "$targetFolder\nssm\nssm.exe" stop ZooKeeper-2
    & "$targetFolder\nssm\nssm.exe" stop ZooKeeper-3

    # remove services
    & "$targetFolder\nssm\nssm.exe" remove ZooKeeper-1 confirm
    & "$targetFolder\nssm\nssm.exe" remove ZooKeeper-2 confirm
    & "$targetFolder\nssm\nssm.exe" remove ZooKeeper-3 confirm

    # remove files
    Write-Host "Removing ZooKeeper files"
    Remove-Item "$targetFolder\zk*" -Recurse
}