# frozen_string_literal: true

require_relative "./route_pack_storage"

module Kanal
  module Application
    module Routing
      #
      # This module can be used to register routing blocks in separate files
      #
      module RoutePack
        class << self
          def configure(&block)
            Kanal::Application::Routing::RoutePackStorage.add_routing_block(&block)
          end
        end
      end
    end
  end
end
