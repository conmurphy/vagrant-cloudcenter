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
    module Errors
      class VagrantCloudcenterError < Vagrant::Errors::VagrantError
        error_namespace("vagrant_cloudcenter.errors")
      end

      class FogError < VagrantAWSError
        error_key(:fog_error)
      end

      class InternalFogError < VagrantAWSError
        error_key(:internal_fog_error)
      end

      class InstanceReadyTimeout < VagrantAWSError
        error_key(:instance_ready_timeout)
      end

      class InstancePackageError < VagrantAWSError
        error_key(:instance_package_error)
      end

      class InstancePackageTimeout < VagrantAWSError
        error_key(:instance_package_timeout)
      end

      class RsyncError < VagrantAWSError
        error_key(:rsync_error)
      end

      class MkdirError < VagrantAWSError
        error_key(:mkdir_error)
      end

    end
  end
end