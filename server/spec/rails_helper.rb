ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rspec/rails'

# Run pending migrations in test environment
ActiveRecord::MigrationContext.new(File.expand_path('../db/migrate', __dir__)).migrate

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end
