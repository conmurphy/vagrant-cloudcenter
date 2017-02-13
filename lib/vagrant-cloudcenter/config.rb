require "vagrant"

module VagrantPlugins
  module Cloudcenter
    class Config < Vagrant.plugin("2", :config)
      # The access key ID for accessing Cloudcenter.
      #
      # @return [String]
      attr_accessor :access_key

      # The Catalog Name for the VM to be provisioned from
      #
      # @return [String]
      attr_accessor :host_ip

      # Comment to use when provisioning the VM
      #
      # @return [String]
      attr_accessor :username

      # JSON config representing the environment to be deployed
      #
      # @return [String]
      attr_accessor :deployment_config

     
      def initialize(region_specific=false)
        @access_key              = UNSET_VALUE
        @host_ip              = UNSET_VALUE
        @host_port		           = UNSET_VALUE
        @username				   = UNSET_VALUE
        @deployment_config          = UNSET_VALUE
	  end
    end
  end
end
