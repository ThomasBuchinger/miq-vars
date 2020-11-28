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
