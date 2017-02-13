module VagrantPlugins
  module Cloudcenter
    module Command
      class Init < Vagrant.plugin("2", :command)
       def self.synopsis
          "Retrieve available catalog items"
        end
        
       # This will build the Vagrantfile and insert the attributes required
        

       def createInitFile()

			script = File.open("Vagrantfile", "w")
			
			script.puts "# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

	config.vm.box = 'cloudcenter'
 
	config.vm.provider :cloudcenter do |cloudcenter|
		cloudcenter.username = 'my_username'
		cloudcenter.access_key = 'my_access_key'
		cloudcenter.host_ip = 'cloudcenter_host_ip_address'
		cloudcenter.deployment_config = 'sample_deployment_config.json'
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