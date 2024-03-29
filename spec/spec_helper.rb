# frozen_string_literal: true

require "rspec/matchers"
require "equivalent-xml"

Dir["./spec/support/**/*.rb"].sort.each { |f| require f }

require "relaton_bsi"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.expose_dsl_globally = true
end

def write_file(file, content)
  File.write file, content, encoding: "UTF-8" unless File.exist? file
end

def read_xml(file)
  File.read(file, encoding: "UTF-8")
    .gsub(/(?<=<fetched>)\d{4}-\d{2}-\d{2}/, Date.today.to_s)
end
