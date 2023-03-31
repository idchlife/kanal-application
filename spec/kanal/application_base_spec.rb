# frozen_string_literal: true

require "kanal/application"
require "kanal/core/core"
require "kanal/plugins/batteries/batteries_plugin"

class TestApp < Kanal::Application::ApplicationBase
  def configure(env = {})
    core.register_plugin Kanal::Plugins::Batteries::BatteriesPlugin.new
    core.router.default_response do
      body "This is default response!"
    end

    add_route_packs_dir File.join(__dir__, "./route_packs")
  end
end

class EnvDependentApp < Kanal::Application::ApplicationBase
  def configure(env = {})
    @core = Kanal::Core::Core.new
    @core.register_plugin Kanal::Plugins::Batteries::BatteriesPlugin.new

    if env[:KANAL_ENV] == :dev
      @core.router.default_response do
        body "Dev default response"
      end

      add_route_pack_file File.join(__dir__, "./route_packs/testing_routes")
    end

    if env[:KANAL_ENV] == :prod
      @core.router.default_response do
        body "Prod default response"
      end

      add_route_pack_file File.join(__dir__, "./route_packs/inner_pack/inner")
    end
  end
end

RSpec.describe Kanal::Application::ApplicationBase do
  it "has a version number" do
    expect(Kanal::Application::VERSION).not_to be nil
  end

  it "loads route packs without errors" do
    test_app = TestApp.new
    test_app.execute_configuration({ KANAL_ENV: :dev })

    core = test_app.core

    input = core.create_input
    input.body = "Hey there"

    output = core.router.create_output_for_input input

    expect(output.body).to include "default response"
  end

  it "works with route packs and gets route from them" do
    test_app = TestApp.new
    test_app.execute_configuration({ KANAL_ENV: :dev })

    core = test_app.core

    input = core.create_input
    input.body = "Inner"

    output = core.router.create_output_for_input input

    expect(output.body).to include "inner route"

    input = core.create_input
    input.body = "Get inside testing"

    output = core.router.create_output_for_input input

    expect(output.body).to include "testing route"
  end

  it "works with configs for :dev env" do
    test_app = EnvDependentApp.new
    test_app.execute_configuration({ KANAL_ENV: :dev })

    core = test_app.core

    input = core.create_input
    input.body = "Inner"

    output = core.router.create_output_for_input input

    expect(output.body).to include "Dev default response"

    input = core.create_input
    input.body = "Get inside testing"

    output = core.router.create_output_for_input input

    expect(output.body).to include "testing route"
  end

  it "works with configs for :prod env" do
    test_app = EnvDependentApp.new
    test_app.execute_configuration({ KANAL_ENV: :prod })

    core = test_app.core

    input = core.create_input
    input.body = "Testing"

    output = core.router.create_output_for_input input

    expect(output.body).to include "Prod default response"

    input = core.create_input
    input.body = "Inner"

    output = core.router.create_output_for_input input

    expect(output.body).to include "inner route"
  end
end
