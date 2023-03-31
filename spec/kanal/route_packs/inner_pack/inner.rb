# frozen_string_literal: true

require "kanal/application"

Kanal::RoutePack.configure do
  on :body, contains: "Inner" do
    respond do
      body "Got inner route"
    end
  end
end
