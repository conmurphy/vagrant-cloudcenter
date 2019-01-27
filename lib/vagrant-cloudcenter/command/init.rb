'Copyright (c) 2019 Cisco and/or its affiliates.

This software is licensed to you under the terms of the Cisco Sample
Code License, Version 1.0 (the "License"). You may obtain a copy of the
License at

               https://developer.cisco.com/docs/licenses

All use of the material herein must be in accordance with the terms of
the License. All rights not expressly granted by the License are
reserved. Unless required by applicable law or agreed to separately in
writing, software distributed under the License is distributed on an "AS
IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
or implied.'

module VagrantPlugins
  module Cloudcenter
    module Command
      class Init < Vagrant.plugin("2", :command)
       def self.synopsis
          "Create inital Vagrant file"
        end
        
       # This will build the Vagrantfile and insert the attributes required
        

       def createInitFile()

			script = File.open("Vagrantfile", "w")
			
			script.puts "# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

	config.vm.box = 'cloudcenter'
 	
 	config.ssh.private_key_path = ['/Users/MYUSERNAME/.ssh/id_rsa','/Users/MYUSERNAME/.vagrant.d/insecure_private_key']
	config.ssh.insert_key = false

	config.vm.provider :cloudcenter do |cloudcenter|
		
		cloudcenter.username = 'my_username'
		cloudcenter.access_key = 'my_access_key'

		cloudcenter.host = 'cloudcenter_host_address'
		cloudcenter.deployment_config = 'sample_deployment_config.json'

		cloudcenter.use_https = true
		cloudcenter.ssl_ca_file = '/path/to/ca_file'

	end
  
  	config.vm.synced_folder '.', '/opt/my_files/', type: 'rsync'

end"
			script.close   

		end
		
		
        
        def execute
          
			createInitFile()
			
        end
      end
    end
  end
end