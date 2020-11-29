#frozen_string_literal: true

require 'thor'
require 'logger'
require 'yaml'

#require_relative '/var/www/miq/vmdb/config/environment' if File.exists?('/var/www/miq/vmdb/config/environment')

lib_dir = __dir__
$LOAD_PATH << lib_dir
require_relative 'version'
require_relative 'miq_var/main'
require_relative 'miq_var/task'
require_relative 'miq_var/cli'

MiqVar.validate
