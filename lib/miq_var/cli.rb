# frozen_string_literal: true
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
      class_option :index, type: :numeric, default: 0, desc: "Select the correct StateMachine, if there are multiple with the same TASK_ID"

      desc "show TASK_ID [all][STATE_VAR, ...]", "Show Information about a given Task (e.g. r1234_miq_provision_1234)"
      def show(task_id, *state_var)
        format = options.fetch(:format, 'short')
        task   = MiqVar.task_by_label(task_id, options[:index])

        puts task.get_details(state_var)
      end

      desc "list", "List currently active requests"
      def list
        puts MiqAeMethodService::MiqAeServiceMiqQueue.where(class_name: 'MiqAeEngine').map{|q| q.tracking_label }.compact
      end

      desc "set TASK_ID KEY JSON_VALUE", "Set (Overwrite) a state variable"
      def set(task_id, key, value)
        task = MiqVar.task_by_label(task_id, options[:index])
        task.set_state_var(key, YAML.load(value))
      end

      desc "edit TASK_ID KEY", "Open state variable in EDITOR"
      def edit(task_id, key)
        task = MiqVar.task_by_label(task_id, options[:index])
        old_value = task.get_state_var(key)
        new_value = MiqVar.open_editor(old_value.to_yaml)
        task.set_state_var(key, YAML.load(new_value))
      end
    end
  end
end
