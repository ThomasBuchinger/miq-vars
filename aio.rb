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
    #$ERROR_INFO.set_backtrace(nil) unless !$settings.nil? && $settings.fetch(:log_level, nil) == :debug
    exit 1
  end
end

# =============================================================
# = CLI configuration
# =============================================================
require 'thor'
module MiqVar
  module Cli
    class MainCli < Thor
      def self.exit_on_failure?
        true
      end
      class_option :index, type: :numeric, default: 0, desc: "Select the correct StateMachine id there are multiple with the same TASK_ID"

      desc "show TASK_ID [all][STATE_VAR, ...]", "Show Information about a given Task (e.g. r1234_miq_provision_1234)"
      def show(task_id, *state_var)
        format = options.fetch(:format, 'short')
        task   = MiqVar.task_by_label(task_id, options[:index])

        puts task.get_details(state_var)
      end

      desc "list", "List currently active requests"
      def list
        puts MiqQueue.where(class_name: 'MiqAeEngine').map{|q| q.tracking_label }.compact
      end

      desc "set TASK_ID KEY JSON_VALUE", "Set (Overwrite) a state variable"
      def set(task_id, key, value)
        task = MiqVar.task_by_label(task_id, options[:index])
        task.set_state_var(key, YAML.load(value))
      end
    end
  end
end


# =============================================================
# = Global Methods
# =============================================================
module MiqVar
  # Check if we run in a ManageIQ rails context
  def self.validate()
    raise "MiqQueue not defined. Are you in a rails context?" unless defined? MiqQueue

  end

  def self.task_by_label(tracking_label, index=0)
    raise "Malformatted task_id #{tracking_label}" unless tracking_label =~ /^r[\d]+/

    MiqVar::Task.new(tracking_label, index)
  end

end
# frozen_string_literal: true

# =============================================================
# = Task Handling
# =============================================================
module MiqVar
  class Task
    attr_reader :miq_queue_object, :data, :tracking_label

    def initialize(tracking_label, index=0)
      @tracking_label = tracking_label
      @miq_queue_object = MiqAeMethodService::MiqAeServiceMiqQueue.where(tracking_label: tracking_label).try(:[], index)
      raise "Unable to find Task: #{@tracking_label}" if @miq_queue_object.blank?
      
      reload()
    end

    def reload()
      @miq_queue_object.reload()
      raise "Task vanished from Queue. (is it finished?)" if @miq_queue_object.blank?

      args = @miq_queue_object.args
      if !args.kind_of? Array || args.try(:compact).try(:length) != 1
        puts args.pretty_inspect
        raise "Arg does not look right! (quiting for safety reasons)"
      end
      @data = args.first
    end

    def set_state_var(key, value)
      reload()

      puts "Setting State Var: #{key} to #{value}"
      vars = YAML.load(@data[:ae_state_data])
      vars[key] = value

      new_data = @data.dup
      new_data[:ae_state_data] = vars.to_yaml
      @miq_queue_object.attributes = {'args': [ new_data ]}
#      puts @miq_queue_object.inspect
      @miq_queue_object.instance_variable_get(:@object).save
      reload()
      puts "="*50
      puts @data.to_yaml
    end

    def get_details(selected_vars)
      lines = []
      user = MiqAeMethodService::MiqAeServiceUser.where(id: @data[:user_id]).first
      state_data = YAML.load(@data[:ae_state_data].presence || "")

      lines << "Task: #{@tracking_label}"
      lines << "  Root: object_type=#{@data[:object_type]} Id=#{@data[:object_id]}"
      lines << "  Automate: URI=#{@data[:namespace]}/#{@data[:class_name]}/#{@data[:instance_name]} Step=#{@data[:state]}"
      lines << "  State: #{@data[:ae_state_retries]} Retries. Next: #{@miq_queue_object.deliver_on}"
      lines << "  User: #{user.userid} (#{user.name})/#{user.current_group.description}"
      lines << "-"*50
      if selected_vars.blank?
        lines << state_data.keys
      elsif selected_vars.include?('all')
        lines << state_data.to_yaml
      else
        lines << state_data.select{|k,_| selected_vars.include?(k) }.to_yaml
      end
      lines << "="*50
      lines
    end
  end
end
MiqVar::Cli::MainCli.start()
