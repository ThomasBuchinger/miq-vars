#frozen_string_literal: true

require_relative '/var/www/miq/vmdb/config/environment' if File.exists?('/var/www/miq/vmdb/config/environment')

lib_dir = __dir__
$LOAD_PATH << lib_dir
require_relative 'version' unless defined? MiqVar::AIO

# Guard against all-in-one script
#
require_relative 'miq_var/main' unless defined? MiqVar::AIO
require_relative 'miq_var/task' unless defined? MiqVar::AIO
require_relative 'miq_var/cli'  unless defined? MiqVar::AIO

