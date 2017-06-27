module VagrantPlugins
  module Cloudcenter
    module Action
      # This can be used with "Call" built-in to check if the machine
      # is stopped and branch in the middleware.
      class IsStopped
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

                if code ==  "DEPLOYMENT_STATUS_NOT_VALID_FOR_OPERATION"
                  puts "\n Error code: #{error['errors'][0]['code']}\n"
                  puts "\n #{error['errors'][0]['message']}\n\n"
                  exit
                else
                  puts "\n Error code: #{error['errors'][0]['code']}\n"
                  puts "\n #{error['errors'][0]['message']}\n\n"
                end

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
                  ));

                rescue => e
                  error = JSON.parse(e.response) 
                  code = error["errors"][0]["code"] 

                  if code ==  "DEPLOYMENT_STATUS_NOT_VALID_FOR_OPERATION"
                    puts "\n Error code: #{error['errors'][0]['code']}\n"
                    puts "\n #{error['errors'][0]['message']}\n\n"
                    exit
                  else
                    puts "\n Error code: #{error['errors'][0]['code']}\n"
                    puts "\n #{error['errors'][0]['message']}\n\n"
                  end

                  exit
                end 

                if response["deploymentEntity"]["attributes"]["health"] == "Healthy"
                  env[:result] = :running
                else 
                  env[:result] = :stopped
                end

              else
                env[:result] = :stopped
              end

          @app.call(env)
        end
      end
    end
  end
end
