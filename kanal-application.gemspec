# frozen_string_literal: true

require_relative "lib/kanal/application/version"

Gem::Specification.new do |spec|
  spec.name = "kanal-application"
  spec.version = Kanal::Application::VERSION
  spec.authors = ["idchlife"]
  spec.email = ["i@pie.studio"]

  spec.summary = "Kanal Application"
  spec.description = "This library can help host Kanal applications, with interfaces, plugins, routes, etc"
  spec.homepage = "https://rubygems.pieq.space"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.6"

  spec.metadata["allowed_push_host"] = "https://rubygems.pieq.space"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://rubygems.pieq.space"
  spec.metadata["changelog_uri"] = "https://rubygems.pieq.space"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "kanal"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
