#
# Module manifest for module 'Solr-Scripting-Helpers'
#
# Generated by: Jeremy Davis
#
# Generated on: 04/09/2019
#
@{

RootModule = 'SolrCloud-Helpers'

# Version number of this module.
ModuleVersion = '1.0'

# ID used to uniquely identify this module
GUID = 'c0a6c63d-8036-46e3-ad29-927408c1170e'

# Author of this module
Author = 'Jeremy Davis'

# Copyright statement for this module
Copyright = '(c) 2019 Jeremy Davis. All rights reserved.'

# Description of the functionality provided by this module
Description = 'A set of helper commandlets for installing SolrCloud'

# Modules that must be imported into the global environment prior to importing this module
RequiredModules = @('7Zip4Powershell')

PrivateData = @{
  PSData = @{
    ExternalModuleDependencies = @('7Zip4Powershell')
  }
}

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = @('Wait-ForZooKeeperInstance','Wait-ForSolrToStart','Make-ZooKeeperEnsemble','Make-ZooKeeperConnection','Make-SolrHostEntry','Make-SolrHostList','Install-OpenJDK','Install-NSSM','Install-ZooKeeperInstance','Start-ZooKeeperInstance','Generate-SolrCertificate','Install-SolrInstance','Add-HostEntries','Start-SolrInstance','Configure-ZooKeeperForSsl','Configure-SolrCollection','Set-SolrConfigForSitecore', 'Remove-FirewallAllowRules', 'Add-FirewallAllowRule')

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = ''

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @()

# HelpInfo URI of this module
# HelpInfoURI = ''

}