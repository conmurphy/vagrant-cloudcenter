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

require "pathname"
require "vagrant/action/builder"


module VagrantPlugins
  module Cloudcenter
    module Command

      include Vagrant::Action::Builtin
      
      class Sync < Vagrant.plugin("2", :command)
     
        def self.synopsis
          "Sync files from host to guest"
        end
        
        def execute

          with_target_vms() do |machine|
            machine.action(:sync)
          end
		       
        end
      end

       
    end
  end
end