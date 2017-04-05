module VagrantPlugins
  module Cloudcenter
    module Action
      # This can be used with "Call" built-in to check if the machine
      # is created and branch in the middleware.
      class IsCreated
        def initialize(app, env)
          @app = app
        end

        def call(env)

              if !File.exists?(env[:machine].provider_config.deployment_config)
                puts "Missing deployment_config file"
                exit
              end

              if !env[:machine_name]
                deployment_config = JSON.parse(File.read(env[:machine].provider_config.deployment_config))
                env[:machine_name] = deployment_config["name"]
              end

              access_key = env[:machine].provider_config.access_key
              host_ip = env[:machine].provider_config.host_ip
              username = env[:machine].provider_config.username

              begin 
                encoded = URI.encode("https://#{username}:#{access_key}@#{host_ip}/v2/jobs?search=[deploymentEntity.name,fle,#{env[:machine_name]}]");           
              
                response = JSON.parse(RestClient::Request.execute(
                        :method => :get,
                        :url => encoded,
                        :verify_ssl => false,
                        :accept => "json",
                        :headers => {"Content-Type" => "application/json"}
                      ));
               
                if !response["jobs"].empty?
                  jobID = response["jobs"][0]["id"]
                end

              rescue => e
                error = JSON.parse(e.response) 
                code = error["errors"][0]["code"] 

                puts "\n Error code: #{error['errors'][0]['code']}\n"
                puts "\n #{error['errors'][0]['message']}\n\n"

                exit
              end 

              if !jobID.nil?
                begin
                  encoded = URI.encode("https://#{username}:#{access_key}@#{host_ip}/v2/jobs/#{jobID}");           
              
                  response = JSON.parse(RestClient::Request.execute(
                    :method => :get,
                    :url => encoded,
                    :verify_ssl => false,
                    :accept => "json",
                    :headers => {"Content-Type" => "application/json"},
                    :payload => deployment_config
                  ));

                rescue => e
                  error = JSON.parse(e.response) 
                  code = error["errors"][0]["code"] 

                  puts "\n Error code: #{error['errors'][0]['code']}\n"
                  puts "\n #{error['errors'][0]['message']}\n\n"

                  exit
                end 

                env[:machine_public_ip] = response["accessLink"][7,response.length]
                env[:machine_ssh_info] = { :host =>  env[:machine_public_ip], :port => 22, :username => "vagrant"}
                env[:ssh_info]  = { :host =>  env[:machine_public_ip], :port => 22, :username => "vagrant"}
                env[:result] = :created

              else
                env[:result] = :not_created
              end
           

          @app.call(env)
        end
      end
    end
  end
end
