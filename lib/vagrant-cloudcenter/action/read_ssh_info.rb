require "log4r"
require "json"

module VagrantPlugins
  module Cloudcenter
    module Action
      # This action reads the SSH info for the machine and puts it into the
      # `:machine_ssh_info` key in the environment.
      class ReadSSHInfo
        def initialize(app, env)
          @app = app
        end

        def call(env)
              
              if !File.exists?(env[:machine].provider_config.deployment_config)
                puts "Missing deployment_config file"
                exit
              end

          if !env[:machine_public_ip]
            
            begin
              
              if !env[:machine_name]
                deployment_config = JSON.parse(File.read(env[:machine].provider_config.deployment_config))
                env[:machine_name] = deployment_config["name"]
              end

              access_key = env[:machine].provider_config.access_key
              host_ip = env[:machine].provider_config.host_ip
              username = env[:machine].provider_config.username

              encoded = URI.encode("https://#{username}:#{access_key}@#{host_ip}/v2/jobs?search=[deploymentEntity.name,fle,#{env[:machine_name]}]");           
            
              response = JSON.parse(RestClient::Request.execute(
                      :method => :get,
                      :url => encoded,
                      :verify_ssl => false,
                      :accept => "json",
                      :headers => {"Content-Type" => "application/json"},
                      :payload => deployment_config
                    ));
              
              jobID = response["jobs"][0]["id"]

              rescue => e
                error = JSON.parse(e.response) 
                code = error["errors"][0]["code"] 

                puts "\n Error code: #{error['errors'][0]['code']}\n"
                puts "\n #{error['errors'][0]['message']}\n\n"

                exit
              end 

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

          end 

          #env[:machine_ssh_info] = { :host =>  env[:machine_public_ip], :port => 22, :username => "vagrant",:private_key_path => env[:machine].config.ssh.private_key_path}

          env[:ssh_info]  = { :host =>  env[:machine_public_ip], :port => 22, :username => "vagrant",:private_key_path => env[:machine].config.ssh.private_key_path}


          @app.call(env)
        end

      end
    end
  end
end
