# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'

RuboCop::RakeTask.new
RSpec::Core::RakeTask.new(:spec)

task default: %i[spec]
task all: %i[spec build all_in_one]

task :all_in_one do |t|
  require 'fileutils'
  dest_path = 'aio.rb'
  
  files = Dir['./exe/**/*.rb', './lib/**/*.rb']
  FileUtils.mkdir_p File.dirname(dest_path)
  FileUtils.rm dest_path if File.exists? dest_path

  puts "Copy source-code to #{dest_path}: #{files}"
  FileUtils.touch(dest_path)
  FileUtils.chmod('+x', dest_path)
  aio_file = File.new(dest_path, 'a')
  files.reverse.each do |src|
    FileUtils.copy_stream(File.new(src), aio_file)
  end
end

