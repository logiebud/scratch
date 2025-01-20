require 'sinatra/activerecord/rake'
require 'rspec/core/rake_task'
require './app'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

# Ensure the test database is properly set up before running tests
namespace :db do
  ENV['RACK_ENV'] = 'test'

  task test_prepare: :environment do
    Rake::Task['db:drop'].execute
    Rake::Task['db:create'].execute
    Rake::Task['db:migrate'].execute
  end
end
