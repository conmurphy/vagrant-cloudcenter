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

require 'vagrant-cloudcenter/action'
require 'highline/import'
require 'colorize'
require 'json'
require 'text-table'
require 'rest-client'

module VagrantPlugins
  module Cloudcenter
    module Command
      class Root < Vagrant.plugin("2", :command)
        def self.synopsis
          "deploy a new environment using Cisco CloudCenter"
        end

        def initialize(argv, env)
          @main_args, @sub_command, @sub_args = split_main_and_subcommand(argv)

          @subcommands = Vagrant::Registry.new
          @subcommands.register(:catalog) do
            require File.expand_path("../catalog", __FILE__)
            Catalog
          end
          @subcommands.register(:app) do
            require File.expand_path("../app", __FILE__)
            App
          end
          @subcommands.register(:jobs) do
            require File.expand_path("../jobs", __FILE__)
            Jobs
          end
          @subcommands.register(:init) do
            require File.expand_path("../init", __FILE__)
            Init
          end
          @subcommands.register(:sync) do
            require File.expand_path("../sync", __FILE__)
            Sync
          end

          super(argv, env)
        end

        def execute
          if @main_args.include?("-h") || @main_args.include?("--help")
            # Print the help for all the  commands.
            return help
          end

          command_class = @subcommands.get(@sub_command.to_sym) if @sub_command
          return help if !command_class || !@sub_command
          @logger.debug("Invoking command class: #{command_class} #{@sub_args.inspect}")

          # Initialize and execute the command class
          command_class.new(@sub_args, @env).execute
        end

        def help
          opts = OptionParser.new do |opts|
            opts.banner = "Usage: vagrant cloudcenter <subcommand> [<args>]"
            opts.separator ""
            opts.separator "Available subcommands:\n"
        
            # Add the available subcommands as separators in order to print them
            # out as well.
            keys = []
            commands = {}
            longest = 0

            @subcommands.each do |key, data| 

              keys << key
              commands[key] = data.synopsis
              longest       = key.length if key.length > longest

            end

            keys.sort.each do |key|
              key.to_sym
              synopsis = commands[key].to_str
              command = key.to_s
              opts.separator "     #{command.ljust(longest+2)} #{synopsis}"
            end

            opts.separator ""
            opts.separator "For help on any individual subcommand run `vagrant cloudcenter <subcommand> -h`"
          end

          @env.ui.info(opts.help, :prefix => false)
        end
      end
    end
  end
end
