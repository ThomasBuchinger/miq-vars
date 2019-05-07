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

# frozen_string_literal: true

require 'thor'
module MiqVar
  module Cli
    class MainCli < Thor
      def self.exit_on_failure?
        true
      end

      desc "show TASK_ID", "Show Information about a given Task (e.g. r1234_miq_provision_1234)"
      def show(task_id)
        task = MiqVar.task_by_label(task_id)
        puts task.get_details()
      end
    end
  end
end
# frozen_string_literal: true

module MiqVar
  # Check if we run in a ManageIQ rails context
  def self.validate()
    raise "MiqQueue not defined. Are you in a rails context?" unless defined? MiqQueue

  end

  def self.task_by_label(tracking_label)
    raise "Malformatted task_id #{tracking_label}" unless tracking_label =~ /^r[\d]+/

    MiqVar::Task.new(tracking_label)
  end

end
# frozen_string_literal: true

module MiqVar
  class Task
    attr_reader :data, :tracking_label

    def initialize(tracking_label)
      @tracking_label = tracking_label
      miq_queue = MiqQueue.where(tracking_label: tracking_label).first
      raise "Unable to find Task: #{@tracking_label}" if miq_queue.blank?
      
      @data = miq_queue.args.first.presence || {}
    end

    def get_details()
      lines = []
      lines << "Task: #{@tracking_label}"
      lines << "  State: #{@data[:state]}: #{@data[:ae_state_retries]} Retriesi. Last at: #{@data[:ae_state_started]} (I have no idea what that timestamp actually is)"
      lines << "  User: #{@data[:user_id]}/#{@data[:miq_group_id]}"
      lines << "-"*50
      lines << YAML.load(@data[:ae_state_data]).to_yaml
      lines << "="*50
      lines
    end
  end
end
MiqVar::Cli::MainCli.start()
