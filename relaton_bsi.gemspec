# frozen_string_literal: true

require_relative "lib/relaton_bsi/version"

Gem::Specification.new do |spec|
  spec.name          = "relaton-bsi"
  spec.version       = RelatonBsi::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["open.source@ribose.com"]

  spec.summary       = "RelatonBsi: retrieve BSI Standards for bibliographic use "\
                       "using the BibliographicItem model"
  spec.description   = "RelatonBsi: retrieve BSI Standards for bibliographic use "\
                       "using the BibliographicItem model"
  spec.homepage      = "https://github.com/metanorma/relaton-bsi"
  spec.license       = "BSD-2-Clause"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.add_development_dependency "equivalent-xml", "~> 0.6"
  spec.add_development_dependency "pry-byebug"
  # spec.add_development_dependency "rake", "~> 13.0"
  # spec.add_development_dependency "rspec", "~> 3.0"
  # spec.add_development_dependency "ruby-debug-ide"
  spec.add_development_dependency "ruby-jing"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "vcr", "~> 5.0.0"
  spec.add_development_dependency "webmock"

  spec.add_dependency "mechanize"
  spec.add_dependency "relaton-iso-bib", "~> 1.7.0"
end
