Function Add-FirewallAllowRule {
    param(
        $solrPort,
        $zooKeeperPort
    )

    $displayName = "Solr (TCP " + $solrPort + ") and ZooKeeper (TCP "+ $zooKeeperPort + ")"
    New-NetFirewallRule -DisplayName $displayName -Direction Inbound -Action Allow -EdgeTraversalPolicy Allow -Protocol TCP -LocalPort $solrPort,$zooKeeperPort
}

Function Remove-FirewallAllowRule {
    Get-NetFirewallRule | Where-Object DisplayName -Like "*Solr*" | Remove-NetFirewallRule
}