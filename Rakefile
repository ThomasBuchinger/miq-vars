# frozen_string_literal: true

require 'bundler/gem_tasks'
def safe_task(gem_name)
  require gem_name
  yield
rescue LoadError
  puts "Cannot load GEM #{gem_name}"
end

safe_task('rubocop/rake_task'){ RuboCop::RakeTask.new }
safe_task('rspec/core/rake_task'){ RSpec::Core::RakeTask.new(:spec) }

task default: %i[spec]
task all: %i[spec build all_in_one]

task :all_in_one do |t|
  require 'fileutils'
  dest_path = 'aio.rb'
  
  files = Dir['./exe/**/*.rb', './lib/**/*.rb']
  FileUtils.mkdir_p File.dirname(dest_path)
  FileUtils.rm dest_path if File.exists? dest_path

  puts "Copy source-code to #{dest_path}: #{files}"
  File.open(dest_path, 'w') { |file| file.write("module MiqVar AIO=true; end\n") }
  FileUtils.chmod('+x', dest_path)
  aio_file = File.new(dest_path, 'a')
  files.reverse.each do |src|
    FileUtils.copy_stream(File.new(src), aio_file)
  end
end

