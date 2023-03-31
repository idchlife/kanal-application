require "kanal/application"

Kanal::Application::Routing::RoutePack.configure do
  on :body, contains: "Get inside testing" do
    respond do
      body "You are inside testing route"
    end
  end
end
