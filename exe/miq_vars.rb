#!/usr/bin/env ruby
# frozen_string_literal: true

require 'thor'
require 'English'
at_exit do
  # Do cleanup

  # Exception or normal exit?
  if $ERROR_INFO
    # Find the correct ExitCode
    # and do not print the stack trace
    $ERROR_INFO.set_backtrace(nil) unless !$settings.nil? && $settings.fetch(:log_level, nil) == :debug
    exit 1
  end
end

require_relative '../lib/miq_var' unless defined? MiqVar::AIO
require_relative '../lib/miq_var/cli' unless defined? MiqVar::AIO

MiqVar::Cli::MainCli.start()
