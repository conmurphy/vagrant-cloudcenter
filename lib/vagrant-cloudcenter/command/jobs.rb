module VagrantPlugins
  module Cloudcenter
    module Command
      class Jobs < Vagrant.plugin("2", :command)
       def self.synopsis
          "Retrieve available jobs"
        end
        
        def execute
          
          	access_key = ""
            username = ""
            host_ip = ""


            if File.exists?("VagrantFile")
				File.readlines("VagrantFile").grep(/cloudcenter.access_key/) do |line|
				    unless line.empty?
				      access_key = line.scan(/["']([^"']*)["']/)[0][0]
				    end
				end
				File.readlines("VagrantFile").grep(/cloudcenter.username/) do |line|
				    unless line.empty?
				      username = line.scan(/["']([^"']*)["']/)[0][0]
				      
				    end
				end
				File.readlines("VagrantFile").grep(/cloudcenter.host_ip/) do |line|
				    unless line.empty?
				      host_ip = line.scan(/["']([^"']*)["']/)[0][0]
				      
				    end
				end
			end

			if access_key.empty?
				access_key = ENV["access_key"]
			end
			if username.empty?
				username = ENV["username"]
			end
			if host_ip.empty?
				host_ip = ENV["host_ip"]
			end


			if access_key.nil?
				puts "Access Key missing. Please enter into VagrantFile or environmental variable 'export access_key= '"
			end
			if username.nil?
				puts "Username missing. Please enter into VagrantFile or environmental variable 'export username= '"
			end
			if host_ip.nil?
				puts "Host IP missing. Please enter into VagrantFile or environmental variable 'export host_ip= '"
			end

			if !(access_key.nil? or username.nil? or host_ip.nil?)
	          	begin

		            encoded = URI.encode("https://#{username}:#{access_key}@#{host_ip}/v2/jobs");           
		            
		            catalog = JSON.parse(RestClient::Request.execute(
		   					:method => :get,
		  					:url => encoded,
		                    :verify_ssl => false,
		                    :content_type => "json",
		                    :accept => "json"
					));
		        
		            catalogs = catalog["jobs"]
				 

					 # build table with data returned from above function
					
					table = Text::Table.new
					table.head = ["ID", "Name", "Family", "Owner","Hours","Status"]
					puts "\n"
				
					#for each item in returned list, display certain attributes in the table
					catalogs.each do |row|
						id = row["id"]
						appName = row["name"]
						family = row["cloudFamily"]
						owner = row["ownerEmailAddress"]
						hours = row["nodeHours"]
						status = row["status"]
						statusMessage = row["jobStatusMessage"]

						table.rows << ["#{id}","#{appName}", "#{family}", "#{owner}", "#{hours}", "#{status}"]
					end
				
					puts table
					
					puts"\n"

	          	rescue => e

		            if e.inspect ==  "Timed out connecting to server"
		              puts "\n#ConnectionError - Unable to connnect to CloudCenter Manager \n"
		              exit
		            else
		              error = JSON.parse(e.response) 
	                  code = error["errors"][0]["code"]

		              puts "\n Error code: #{error['errors'][0]['code']}\n"
	                  puts "\n #{error['errors'][0]['message']}\n\n"

		              exit
		            end
				end	
			end
          
         	0
          
		  
				
        end
      end
    end
  end
end