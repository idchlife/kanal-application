require_relative "./application/version"
require_relative "./application/routing/route_pack"
require_relative "./application/application_base"

module Kanal
  module Application
  end

  # Shortcuts
  RoutePack = Kanal::Application::Routing::RoutePack

  ApplicationBase = Kanal::Application::ApplicationBase
end
