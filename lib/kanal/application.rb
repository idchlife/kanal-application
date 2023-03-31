require_relative "./application/version"
require_relative "./application/routing/route_pack"
require_relative "./application/application_base"

module Kanal
  module Application
  end

  module RoutePack
    include Kanal::Application::Routing::RoutePack
  end

  module ApplicationBase
    include Kanal::Application::ApplicationBase
  end
end
