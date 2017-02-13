require "log4r"

require 'vagrant/util/retryable'

require 'vagrant-cloudcenter/util/timer'

module VagrantPlugins
  module Cloudcenter
    module Action
      # This starts a stopped instance.
      class StartInstance
        include Vagrant::Util::Retryable

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("cloudcenter::action::start_instance")
        end

        def call(env)
              if !File.exists?(env[:machine].provider_config.deployment_config)
                puts "Missing deployment_config file"
                exit
              end
               
          countdown = 24

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
                puts "Error \n"
                puts e
              end 

              if !jobID.nil?
                begin
                  encoded = URI.encode("https://#{username}:#{access_key}@#{host_ip}/v2/jobs/#{jobID}");           
              
                  payload = { "action" => "RESUME" }

                  payload = JSON.generate(payload)

                  response = JSON.parse(RestClient::Request.execute(
                    :method => :put,
                    :url => encoded,
                    :verify_ssl => false,
                    :accept => "json",
                    :headers => {"Content-Type" => "application/json"},
                    :payload => payload
                  ));

                rescue => e
                  puts "Error \n"
                  puts e
                end 
                 
                      while (countdown > 0 )
                        
                        countdown -= 1

                        begin
                            encoded = URI.encode("https://#{username}:#{access_key}@#{host_ip}/v2/jobs/#{jobID}");           
                            
                            response = JSON.parse(RestClient::Request.execute(
                                    :method => :get,
                                    :url => encoded,
                                    :verify_ssl => false,
                                    :accept => "json",
                                    :headers => {"Content-Type" => "application/json"},
                                    
                            ))
                        rescue => e
                          puts "Error \n"
                          puts e
                        end

                        if response["deploymentEntity"]["attributes"]["status"] == "Deployed"       
                          env[:state] = :stopped
                          env[:ui].info(I18n.t("cloudcenter.ready"))
                          break
                        else
                          env[:ui].info(I18n.t("cloudcenter.starting"))
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
