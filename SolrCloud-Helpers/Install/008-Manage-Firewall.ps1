Function Add-FirewallAllowRule {
    param(
        [Parameter(Mandatory)][Int32]$solrPort,
        [Parameter(Mandatory)][Int32]$zooKeeperClientPort,
        [Parameter(Mandatory)][Int32]$zooKeeperPeerPort,
        [Parameter(Mandatory)][Int32]$zooKeeperElectionPort
    )

    $displayName = "Solr (TCP " + $solrPort + ") and ZooKeeper (TCP " + $zooKeeperClientPort + ", " + $zooKeeperPeerPort  + ", " + $zooKeeperElectionPort +  ")"
    New-NetFirewallRule -DisplayName $displayName -Direction Inbound -Action Allow -EdgeTraversalPolicy Allow -Protocol TCP -LocalPort $solrPort,$zooKeeperClientPort, $zooKeeperPeerPort, $zooKeeperElectionPort
}

Function Remove-FirewallAllowRules {
    Get-NetFirewallRule | Where-Object DisplayName -Like "*Solr*" | Remove-NetFirewallRule
}

Export-ModuleMember -Function Add-FirewallAllowRule
Export-ModuleMember -Function Remove-FirewallAllowRules