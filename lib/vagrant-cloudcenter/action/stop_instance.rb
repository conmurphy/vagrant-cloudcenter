require "log4r"

module VagrantPlugins
  module Cloudcenter
    module Action
      # This stops the running instance.
      class StopInstance

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("cloudcenter::action::stop_instance")
        end

        def call(env)
          countdown = 24

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
              
                  payload = { "action" => "SUSPEND" }

                  payload = JSON.generate(payload)

                  response = JSON.parse(RestClient::Request.execute(
                    :method => :put,
                    :url => encoded,
                    :verify_ssl => false,
                    :accept => "json",
                    :payload => payload,
                    :headers => {"Content-Type" => "application/json"}
                  ));

                rescue => e
                  error = JSON.parse(e.response) 
                  code = error["errors"][0]["code"] 

                  puts "\n Error code: #{error['errors'][0]['code']}\n"
                  puts "\n #{error['errors'][0]['message']}\n\n"

                  exit
                end 
                 
                      while (countdown > 0 )
                        
                        countdown -= 1

                        begin
                            encoded = URI.encode("https://#{username}:#{access_key}@#{host_ip}/v2/jobs/#{jobID}");           
                            
                            response = JSON.parse(RestClient::Request.execute(
                                    :method => :get,
                                    :url => encoded,
                                    :verify_ssl => false,
                                    :accept => "json"
                                    
                            ))
                        rescue => e
                          error = JSON.parse(e.response) 
                          code = error["errors"][0]["code"] 

                          puts "\n Error code: #{error['errors'][0]['code']}\n"
                          puts "\n #{error['errors'][0]['message']}\n\n"
                        
                          exit
                        end

                        if response["deploymentEntity"]["attributes"]["status"] == "Suspended"       
                          env[:state] = :stopped
                          env[:ui].info(I18n.t("cloudcenter.stopped"))
                          break
                        else
                          env[:ui].info(I18n.t("cloudcenter.stopping"))
                        end
                        
                        sleep 20

                      end 
                  
    
              end
                
          @app.call(env)
        end
      end
    end
  end
end
