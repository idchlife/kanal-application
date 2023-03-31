# frozen_string_literal: true

require "kanal/core/core"
require_relative "./routing/route_pack_storage"
require_relative "./helpers/file_loader"

module Kanal
  module Application
    class Error < StandardError; end

    #
    # Base application class provides ability to extend it and implement
    # your own application
    #
    class ApplicationBase
      attr_reader :core

      RoutePacksDirInfo = Struct.new(:path, :recursive)

      def initialize
        @route_packs_dirs = []
        @route_pack_files = []
        @core = nil
        @interface_initialization_blocks = {}
        @enabled_interface_name = nil
        @environments = {}

        @configuration_initialized = false

        Kanal::Application::Routing::RoutePackStorage.clear_routing_blocks
      end

      #
      # All application configuration happens here.
      # Routes, plugins, interfaces, env dependent code, etc.
      #
      # @param env [Hash] env will be provided on app start
      #
      # @return [void] <description>
      #
      def configure(env)
        raise NotImplementedError
      end

      #
      # This method adds interface for lazy initialization
      # on demand. Always requires block that will return interface
      #
      # @param name [Symbol] <description>
      # @param &block [Proc] block will be provided with |core| argument
      #
      # @return [void] <description>
      #
      def register_interface(name, &block)
        if @interface_initialization_blocks.keys.include? name
          raise "Duplicate interface initializator named `#{name}`. Please specify another name"
        end

        @interface_initialization_blocks[name] = block
      end

      #
      # Enables one and only interface to start in this
      # application
      #
      # @param name [Symbol] name of interface to enable
      #
      # @return [void] <description>
      #
      def enable_interface(name)
        @enabled_interface_name = name
      end

      #
      # Add directory filled with route pack files which use
      # Kanal::Application::Routing::RoutePack.configure do; end for configuring routes
      # Recursive option is true by default
      #
      # WARNING: there is no duplicate route pack files check,
      # so it's better to add one/several independent directories
      # If you add same directory multiple times - it will probably
      # give you duplicated routes
      #
      # @param path [String] <description>
      # @param recursive [Boolean] <description>
      #
      # @return [void] <description>
      #
      def add_route_packs_dir(path, recursive: true)
        @route_packs_dirs << RoutePacksDirInfo.new(path, recursive)
      end

      #
      # Method for starting application
      #
      # @param env [Hash] hash with environment variables, by default uses ENV
      #
      # @return [void] <description>
      #
      def start(env = ENV)
        execute_configuration env

        interface.start
      end

      private :core

      #
      # Returns enabled interface
      #
      # @return [Kanal::Core::Interfaces::Interface] <description>
      #
      def enabled_interface
        raise "Please enable at least one interface" if @enabled_interface_name.nil?

        @interface_initialization_blocks[@enabled_interface_name].call @core
      end

      def execute_configuration(env)
        # KANAL_ENV variable should be always defined
        env[:KANAL_ENV] = :dev unless env.key? :KANAL_ENV

        # Convert kanal environment to symbol, because KANAL_ENV should always be symbol
        env[:KANAL_ENV] = env[:KANAL_ENV].to_sym

        # Creating core
        @core = Kanal::Core::Core.new

        # Using configuration provided by dev
        configure env

        # Loading route pack files from dires
        load_route_packs_dirs

        # Getting routing blocks from route pack storage
        routing_blocks = Kanal::Application::Routing::RoutePackStorage.routing_blocks

        # Adding routing blocks to router configuration
        routing_blocks.each do |b|
          @core.router.configure(&b)
        end
      end

      def load_route_packs_dirs
        @route_packs_dirs.each do |dir_info|
          Kanal::Application::Helpers::FileLoader.load_ruby_files_from_dir dir_info.path, recursive: dir_info.recursive
        rescue Exception => e
          raise "Error loading route packs from dir #{dir_info.path}. More info about the error: #{e.full_message}"
        end
      end
    end
  end
end
