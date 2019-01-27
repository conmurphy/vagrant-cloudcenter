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
              host = env[:machine].provider_config.host
              username = env[:machine].provider_config.username

              use_https = env[:machine].provider_config.use_https
              ssl_ca_file = env[:machine].provider_config.ssl_ca_file
            
              begin 
                encoded = URI.encode("https://#{username}:#{access_key}@#{host}/v2/jobs?search=[deploymentEntity.name,fle,#{env[:machine_name]}]");           
            
                if !use_https
                  response = JSON.parse(RestClient::Request.execute(
                        :method => :get,
                        :url => encoded,
                        :verify_ssl => false,
                        :accept => "json",
                        :headers => {"Content-Type" => "application/json"}
                      ));
                else
                  if ssl_ca_file.to_s.empty?
                    response = JSON.parse(RestClient::Request.execute(
                        :method => :get,
                        :url => encoded,
                        :accept => "json",
                        :headers => {"Content-Type" => "application/json"}
                      ));
                  else
                    response = JSON.parse(RestClient::Request.execute(
                        :method => :get,
                        :url => encoded,
                        :ssl_ca_file => ssl_ca_file.to_s,
                        :accept => "json",
                        :headers => {"Content-Type" => "application/json"}
                      ));
                  end
                  
                end

                
               
                if !response["jobs"].empty?
                  jobID = response["jobs"][0]["id"]
                end

              rescue => e
                
                if e.to_s == "SSL_connect returned=1 errno=0 state=error: certificate verify failed"
                  puts "\n ERROR: Failed to verify certificate\n\n"
                  exit
                elsif e.to_s == "401 Unauthorized"
                  puts "\n ERROR: Incorrect credentials\n\n"
                  exit
                elsif e.to_s == "hostname \"#{host}\" does not match the server certificate"
                  puts "\n ERROR: Hostname \"#{host}\" does not match the server certificate\n\n"
                  exit
                elsif e.to_s.include? "No route to host"
                  puts "\n ERROR: No route to host. Check connectivity and try again\n\n"
                  exit
                elsif e.to_s.== "Timed out connecting to server"
                  puts "\n ERROR: Timed out connecting to server. Check connectivity and try again\n\n"
                  exit
                elsif e.to_s.== "getaddrinfo: nodename nor servname provided, or not known"
                  puts "\n ERROR: Unable to connect to \"#{host}\" \n\n"
                  exit
                else
                  error = JSON.parse(e.response) 
                  code = error["errors"][0]["code"] 

                  puts "\n Error code: #{error['errors'][0]['code']}\n"
                  puts "\n #{error['errors'][0]['message']}\n\n"

                  exit
                end
              end 

              if !jobID.nil?
                begin
                  encoded = URI.encode("https://#{username}:#{access_key}@#{host}/v2/jobs/#{jobID}");           
              
                  if !use_https
                    response = JSON.parse(RestClient::Request.execute(
                      :method => :get,
                      :url => encoded,
                      :verify_ssl => false,
                      :accept => "json"
                    ));
                  else
                    if ssl_ca_file.to_s.empty?
                      response = JSON.parse(RestClient::Request.execute(
                        :method => :get,
                        :url => encoded,
                        :accept => "json"
                      ));
                    else
                      response = JSON.parse(RestClient::Request.execute(
                        :method => :get,
                        :url => encoded,
                        :ssl_ca_file => ssl_ca_file.to_s,
                        :accept => "json"
                      ));
                    end
                  end

                rescue => e
                   
                if e.to_s == "SSL_connect returned=1 errno=0 state=error: certificate verify failed"
                  puts "\n ERROR: Failed to verify certificate\n\n"
                  exit
                elsif e.to_s == "401 Unauthorized"
                  puts "\n ERROR: Incorrect credentials\n\n"
                  exit
                elsif e.to_s == "hostname \"#{host}\" does not match the server certificate"
                  puts "\n ERROR: Hostname \"#{host}\" does not match the server certificate\n\n"
                  exit
                elsif e.to_s.include? "No route to host"
                  puts "\n ERROR: No route to host. Check connectivity and try again\n\n"
                  exit
                elsif e.to_s.== "Timed out connecting to server"
                  puts "\n ERROR: Timed out connecting to server. Check connectivity and try again\n\n"
                  exit
                elsif e.to_s.== "getaddrinfo: nodename nor servname provided, or not known"
                  puts "\n ERROR: Unable to connect to \"#{host}\" \n\n"
                  exit
                else
                  error = JSON.parse(e.response) 
                  code = error["errors"][0]["code"] 

                  puts "\n Error code: #{error['errors'][0]['code']}\n"
                  puts "\n #{error['errors'][0]['message']}\n\n"

                  exit
                end
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
