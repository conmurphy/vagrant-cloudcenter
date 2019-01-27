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

require "vagrant"

module VagrantPlugins
  module Cloudcenter
    class Config < Vagrant.plugin("2", :config)
      # The access key ID for accessing Cloudcenter.
      #
      # @return [String]
      attr_accessor :access_key

      # The address of the host
      #
      # @return [String]
      attr_accessor :host

      # Comment to use when provisioning the VM
      #
      # @return [String]
      attr_accessor :username

      # JSON config representing the environment to be deployed
      #
      # @return [String]
      attr_accessor :deployment_config

      # Whether or not to use HTTPS
      #
      # @return [boolean]
      attr_accessor :use_https

      # Path to the SSL CA file
      #
      # @return [String]
      attr_accessor :ssl_ca_file

      def initialize()
        @access_key = UNSET_VALUE
        @host = UNSET_VALUE
        @username = UNSET_VALUE
        @deployment_config = UNSET_VALUE
        @use_https = true
        @ssl_ca_file = ''
	  end
    end
  end
end
