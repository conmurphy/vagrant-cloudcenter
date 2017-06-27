# Cisco CloudCenter Vagrant Plugin - Proof of Concept

This is a Vagrant plugin that adds a Cisco CloudCenter provider to Vagrant. It allows Vagrant to communicate with CloudCenter and have it control and provision machines in a number of public and private clouds. 

This plugin is currently a Proof of Concept and has been developed and tested against Cisco CloudCenter 4.8.0 and Vagrant 1.2+

![alt tag](https://github.com/conmurphy/vagrant-cloudcenter/blob/master/images/overview.png)

Table of Contents
=================

   * [Cisco CloudCenter Vagrant Plugin - Proof of Concept](#cisco-cloudcenter-vagrant-plugin---proof-of-concept)
   * [Table of Contents](#table-of-contents)
      * [Features](#features)
      * [Usage](#usage)
      * [Vagrantfile structure](#vagrantfile-structure)
      * [Installation](#installation)
      * [Box Format](#box-format)
      * [Configuration](#configuration)
      * [Synced Folders](#synced-folders)
      * [Development](#development)
      
Created by [gh-md-toc](https://github.com/ekalinin/github-markdown-toc)

## Features

* Boot instances through CloudCenter
* SSH into the instances
* Provision the instances with any built-in Vagrant provisioner
* Minimal synced folder support via `rsync`

## Usage

After installing the plugin use the `vagrant up` command an specify the `cloudcenter`  provider.

```
$ vagrant up --provider=cloudcenter
...
```

The following additional plugin commands have been provided:

* `vagrant cloudcenter init` - Create a template Vagrantfile and populate with your own configuration
* `vagrant cloudcenter catalog` - Return a list of the current available catalog 
* `vagrant cloudcenter jobs` - Return a list of service requests and their current status

## Vagrantfile structure 

You can either manually create a Vagrantfile that looks like the following, filling in
your information where necessary, or run the `vagrant cloudcenter init` command to have an empty Vagrantfile created for you.

```
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

	config.vm.box = 'cloudcenter'
	
 	config.ssh.private_key_path = ['/Users/MYUSERNAME/.ssh/id_rsa','/Users/MYUSERNAME/.vagrant.d/insecure_private_key']
	config.ssh.insert_key = false
	
	config.vm.provider :cloudcenter do |cloudcenter|
		cloudcenter.username = 'my_username'
		cloudcenter.access_key = 'my_access_key'
		cloudcenter.host_ip = 'cloudcenter_host_ip_address'
		cloudcenter.deployment_config = 'sample_deployment_config.json'
	end
  
  	config.vm.synced_folder '.', '/opt/my_files/', type: 'rsync'

end
```

## Installation

## Box Format

The Vagrant CloudCenter plugin requires a box with configuration as outlined in this document.

[Vagrant Box Format]( https://www.vagrantup.com/docs/boxes/base.html ) 

* "vagrant" User
* Root Password: "vagrant"
* Password-less Sudo
* SSH Tweaks

## Configuration

This provider exposes quite a few provider-specific configuration options:

* `access_key` - The access key for accessing the Cisco CloudCenter API
* `username` - The username for accessing the  CloudCenter API
* `host_ip` - The host IP address of the CloudCenter Manager
* `deployment_config` - A JSON file used by CloudCenter to deploy the desired infrastructure

## Deployment Config

This is a JSON file used by Cisco CloudCenter to deploy a new application into the environment of your choosing. It can be created by following these steps:

1. Access the application from the CCM UI and click Applications
2. Search for the required application in the Applications page
3. Select `Deploy` 

![alt tag](https://github.com/conmurphy/vagrant-cloudcenter/blob/master/images/AppProfiles.png)

4. Complete the required fields
5. Select `Restful JSON`

![alt tag](https://github.com/conmurphy/vagrant-cloudcenter/blob/master/images/AppDeployment.png)

6. Save the JSON output into a new file on your local machine
7. Use this file in the `cloudcenter.deployment_config` setting

## Synced Folders

There is minimal support for synced folders. Upon `vagrant up`,
`vagrant reload`, and `vagrant provision`, the CloudCenter provider will use
`rsync` (if available) to uni-directionally sync the folder to
the remote machine over SSH.

See [Vagrant Synced folders: rsync](https://docs.vagrantup.com/v2/synced-folders/rsync.html)

## Guidelines and Limitations

* Currently tested with a single tier VM 

## Development

To work on the CloudCenter plugin, clone this repository then run the following commands to build and install the plugin.

```
$ gem build vagrant-cloudcenter.gemspec
$ vagrant plugin install ./vagrant-cloudcenter-0.1.0.gem
```

To uninstall the plugin run `vagrant plugin uninstall vagrant-cloudcenter`

WARNING:

These scripts are meant for educational/proof of concept purposes only. Any use of these scripts and tools is at your own risk. There is no guarantee that they have been through thorough testing in a comparable environment and we are not responsible for any damage or data loss incurred with their use.
