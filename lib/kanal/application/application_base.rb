# frozen_string_literal: true

require "kanal/core/core"
require_relative "./routing/route_pack_storage"
require_relative "./helpers/file_loader"

module Kanal
  module Application
    class Error < StandardError; end

    RoutePacksDir = Struct.new(:path, :recursive)

    #
    # Base application class provides ability to extend it and implement
    # your own application
    #
    class ApplicationBase
      include Kanal::Application::Helpers

      attr_reader :core

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
      # @return [<Type>] <description>
      #
      def register_interface(name, &block)
        if @interface_initialization_blocks.keys.include? name
          raise "Duplicate interface initializator named `#{name}`. Please specify another name"
        end
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

      def add_route_packs_dir(path, recursive = false)
        return if @route_packs_dirs.include? path

        @route_packs_dirs << path
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

        # Creating core
        @core = Kanal::Core::Core.new

        configure env

        load_route_packs_dirs

        routing_blocks = Kanal::Application::Routing::RoutePackStorage.routing_blocks

        # Adding routing blocks to router configuration
        routing_blocks.each do |b|
          @core.router.configure(&b)
        end
      end

      def load_route_packs_dirs
        @route_packs_dirs.each do |dir|
          FileLoader.load_ruby_files_from_dir dir
        end
      rescue Exception => e
        raise "Error loading route packs #{dir}. More info about the error: #{e}"
      end
    end
  end
end
