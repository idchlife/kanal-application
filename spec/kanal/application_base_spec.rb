# frozen_string_literal: true

require "kanal/application"
require "kanal/core/core"
require "kanal/plugins/batteries/batteries_plugin"

class TestApp < Kanal::Application::ApplicationBase
  def configure(env)
    core.register_plugin Kanal::Plugins::Batteries::BatteriesPlugin.new
    core.router.default_response do
      body "This is default response!"
    end

    add_route_packs_dir File.join(__dir__, "./route_packs")
  end
end

class EnvDependentApp < Kanal::Application::ApplicationBase
  def configure(env)
    core.register_plugin Kanal::Plugins::Batteries::BatteriesPlugin.new

    if env[:KANAL_ENV] == :dev
      core.router.default_response do
        body "Dev default response"
      end

      add_route_packs_dir File.join(__dir__, "./route_packs/another_pack")
    end

    if env[:KANAL_ENV] == :prod
      core.router.default_response do
        body "Prod default response"
      end

      add_route_packs_dir File.join(__dir__, "./route_packs/inner_pack")
    end
  end
end

#
# @param app [Kanal::Application::ApplicationBase] <description>
#
# @return [Kanal::Core::Core] <description>
#
def obtain_core_from_app(app)
  app.instance_variable_get(:@core)
end

RSpec.describe Kanal::Application::ApplicationBase do
  it "has a version number" do
    expect(Kanal::Application::VERSION).not_to be nil
  end

  it "loads route packs without errors" do
    test_app = TestApp.new
    test_app.execute_configuration({ KANAL_ENV: :dev })

    core = obtain_core_from_app(test_app)

    input = core.create_input
    input.body = "Hey there"

    output = nil

    core.router.output_ready do |o|
      output = o
    end

    core.router.consume_input input

    expect(output.body).to include "default response"
  end

  it "works with route packs and properly fills router with routes configuration" do
    test_app = TestApp.new
    test_app.execute_configuration({ KANAL_ENV: :dev })

    core = obtain_core_from_app(test_app)

    input = core.create_input
    input.body = "Inner"

    output = nil

    core.router.output_ready do |o|
      output = o
    end

    cr = core.router

    core.router.consume_input input

    expect(output.body).to include "inner route"

    input = core.create_input
    input.body = "Get inside testing"

    output = nil

    core.router.consume_input input

    expect(output.body).to include "testing route"
  end

  it "works with configs for :dev env" do
    test_app = EnvDependentApp.new
    test_app.execute_configuration({ KANAL_ENV: :dev })

    core = obtain_core_from_app(test_app)

    input = core.create_input
    input.body = "Inner"

    output = nil

    core.router.output_ready do |o|
      output = o
    end

    core.router.consume_input input

    expect(output.body).to include "Dev default response"

    input = core.create_input
    input.body = "Get inside testing"

    output = nil

    core.router.consume_input input

    expect(output.body).to include "testing route"
  end

  it "works with configs for :prod env" do
    test_app = EnvDependentApp.new
    test_app.execute_configuration({ KANAL_ENV: :prod })

    core = obtain_core_from_app(test_app)

    input = core.create_input
    input.body = "Testing"

    output = nil

    core.router.output_ready do |o|
      output = o
    end

    core.router.consume_input input

    expect(output.body).to include "Prod default response"

    input = core.create_input
    input.body = "Inner"

    output = nil

    core.router.consume_input input

    expect(output.body).to include "inner route"
  end
end
