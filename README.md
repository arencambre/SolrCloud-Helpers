# SolrCloud Install Scripts

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This automates setting up SolrCloud clusters on Windows. It helps with developer and production instances.

## What this does not do

* **Use SSL.** Due to some special requirements at my workplace, I have temporarily commented out all functionality that implements SSL. I may add it back at some point.
* **Set up initial collections.** While there is code in here that used to do that, it appears to have been designed for a prior release of Solr. It does not play nicely with Solr 8.8.2. For now, I am using Sitecore's **solr-init** container to create initial collections.

## Using the scripts

General procedure:

1. Make a copy of this repository to a directory on the server you want to set up Solr and ZooKeeper on.
1. Make copies of **solr_config.sample.json** and **zookeeper_config.sample.json**, but remove **.sample** from the filenames. By default, these are set up for a triple instance of Solr and ZooKeeper on a single developer environment. Adjust them to reflect the properties of the servers you want to set up the ensemble on. If this is a production setup, then you will need to copy these two JSON files to all servers you're setting up Solr and ZooKeeper on.
1. In **Setup-OpenJDK.ps1**, edit the `$targetFolder` variable. See the **Variables to configure** section below for clarification.
1. Run **Setup-OpenJDK.ps1** in a PowerShell window with administrative privileges.
1. Edit **Setup-SingleInstance.ps1** if you're setting up a single production instance or **Setup-TripleInstance.ps1** if you're setting up a triple instance. See the **Variables to configure** section below for clarification on all the variables you may need to edit.
1. Run **Setup-SingleInstance.ps1** or **Setup-TripleInstance.ps1**.

## Variables to configure

Here's variables you'll need to configure in various PS1 files:
* `$targetFolder`: An absolute path to where you want the Zookeeper and Solr files installed to? If this folder does not exist
  it will be created.
* `$installService`: A boolean flag to specifiy whether NSSM services should be installed for Solr and ZooKeeper. If this is `true`, both will run automatically upon each machine boot. If `false`, you must manually run these products _and_ you will need to manually start each of these at appropriate points in the script.
* `$collectionPrefix`: The name of your Sitecore instance, which is added to the beginning of the names of your collections.
* `$solrPackage`: The URL for downloading the right Solr version. The default given is Solr 8.8.2, which Sitecore 10.2 requires.
* `$zkPackage`: The URL for downloading the right ZooKeeper version. The default given is for ZooKeeper 3.6.2, which Solr 8.8.2 requires.