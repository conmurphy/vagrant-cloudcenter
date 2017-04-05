module VagrantPlugins
  module Cloudcenter
    module Command
      class App < Vagrant.plugin("2", :command)
       def self.synopsis
          "Retrieve application details"
        end
        
        def execute
          
          	RestClient.log = 'stdout'
           	# Get the rest API key for authentication
	        

			host_ip =  ENV['host_ip']
			access_key =  ENV['access_key']
			username =  ENV['username']

			options = {}
			options[:force] = false

			opts = OptionParser.new do |o|
			  o.banner = "Usage: vagrant cloudcenter app [application-id]"
			  o.separator ""

			end

			# Parse the options
			argv = parse_options(opts)

			puts argv[0]

          	begin

	          	if argv[0] && argv[0].match(/\A\d+\z/)

		            encoded = URI.encode("https://#{username}:#{access_key}@#{host_ip}/v1/apps/#{argv[0]}");           
		            
		            catalog = JSON.parse(RestClient::Request.execute(
		   					:method => :get,
		  					:url => encoded,
		                    :verify_ssl => false,
		                    :content_type => "json",
		                    :accept => "json"
											));
		            puts JSON.pretty_generate(catalog)

				end
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
			
          
         	0
          
		  
				
        end
      end
    end
  end
end