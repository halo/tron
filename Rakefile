# frozen_string_literal: true

require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new do |t|
  t.pattern = 'spec.rb'
end

require 'rubocop/rake_task'
RuboCop::RakeTask.new

task default: %i[spec rubocop]
