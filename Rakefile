# frozen_string_literal: true

require_relative "config/application"
require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "standard/rake"

Dir.glob("#{File.expand_path(__dir__)}/lib/tasks/**/*.rake").each { |f| load f }

task default: %i[spec standard]
