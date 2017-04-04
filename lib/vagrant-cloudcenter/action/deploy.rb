
require "log4r"
require 'rest-client';
require 'json';
require 'base64'

require 'vagrant/util/retryable'

require 'vagrant-cloudcenter/util/timer'

module VagrantPlugins
  module Cloudcenter
    module Action
     
      class Deploy
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("cloudcenter::action::connect")
        end

        def call(env)
          
          # Get the rest API key for authentication
          access_key = env[:machine].provider_config.access_key
          host_ip = env[:machine].provider_config.host_ip
          username = env[:machine].provider_config.username
  			
          countdown = 24

          #@logger.info("Deploying VM to Cloudcenter...")

          begin

            if !File.exists?(env[:machine].provider_config.deployment_config)
              puts "\nMissing deployment_config file\n\n"
              exit
            end

            deployment_config = File.read(env[:machine].provider_config.deployment_config)
            tmp = JSON.parse(deployment_config)
            env[:machine_name] = tmp["name"]

            encoded = URI.encode("https://#{username}:#{access_key}@#{host_ip}/v2/jobs");           
            
            env[:cloudcenter_connect] = JSON.parse(RestClient::Request.execute(
   									:method => :post,
  									:url => encoded,
                    :verify_ssl => false,
                    :accept => "json",
                    :headers => {"Content-Type" => "application/json"},
                    :payload => deployment_config
									));

            response = env[:cloudcenter_connect]
            
            jobID = response["id"]

            encoded = URI.encode("https://#{username}:#{access_key}@#{host_ip}/v2/jobs/#{jobID}");           
                      
            response = JSON.parse(RestClient::Request.execute(
              :method => :get,
              :url => encoded,
              :verify_ssl => false,
              :accept => "json",
              :headers => {"Content-Type" => "application/json"},
                              
            ))

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

            status = response["status"]

                # Wait for SSH to be ready.
                env[:ui].info(I18n.t("cloudcenter.waiting_for_ready"))
               
                while countdown > 0

                  countdown -= 1
                  
                  # When an  instance comes up, it's networking may not be ready
                  # by the time we connect.
                  begin

                      jobID = response["id"]

                      encoded = URI.encode("https://#{username}:#{access_key}@#{host_ip}/v2/jobs/#{jobID}");           
                      
                      response = JSON.parse(RestClient::Request.execute(
                              :method => :get,
                              :url => encoded,
                              :verify_ssl => false,
                              :accept => "json",
                              :headers => {"Content-Type" => "application/json"},
                              
                      ))

                      status = response["status"]
                      
                      
                      if status == "JobRunning" then 
                        env[:machine_state_id]= :created
                        break
                      elsif status == "JobStarting" || status == "JobSubmitted" || status == "JobInProgress" || status == "JobResuming"
                        env[:ui].info(I18n.t("cloudcenter.waiting_for_ssh"))
                      elsif status == "JobError" 
                        puts "\nError deploying VM...\n"
                        puts "\n#{response['jobStatusMessage']}\n\n"
                        exit
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

                  sleep 20
                end
             
            env[:machine_public_ip] = response["accessLink"][7,response.length]
        
            # Ready and booted!
            env[:ui].info(I18n.t("cloudcenter.ready"))
         

          @app.call(env)
        end
      end
    end
  end
end
