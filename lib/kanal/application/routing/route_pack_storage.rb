# frozen_string_literal: true

module Kanal
  module Application
    module Routing
      #
      # This module is for internal usage only. It stores all registered routing blocks that were registered via RoutePack.configure
      #
      module RoutePackStorage
        class << self
          @@_routing_blocks = []

          def add_routing_block(&block)
            return if @@_routing_blocks.include? block

            @@_routing_blocks << block
          end

          def clear_routing_blocks
            @@_routing_blocks = []
          end

          def routing_blocks
            @@_routing_blocks
          end
        end
      end
    end
  end
end
