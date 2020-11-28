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
