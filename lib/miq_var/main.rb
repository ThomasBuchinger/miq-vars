# frozen_string_literal: true
# =============================================================
# = Global Methods
# =============================================================
require 'tempfile'

module MiqVar
  # Check if we run in a ManageIQ rails context
  def self.validate()
    # Use native Rails object, not Automate, because MiqAeMethodService uses const_missing to wrap
    raise "MiqQueue not defined. Are you in a rails context?" unless defined? MiqQueue
  end

  def self.task_by_label(tracking_label, index=0)
    raise "Malformatted task_id #{tracking_label}" unless tracking_label =~ /^r[\d]+/ || tracking_label.start_with?('resource_action')

    MiqVar::Task.new(tracking_label, index)
  end

  def self.open_editor(data)
    editor = ENV['EDITOR']
    raise "No $EDITOR variable present" if editor.nil? || editor.empty?

    # Prepare file with existing data
    f = Tempfile.new('miq-vars-tmp')
    begin f.puts(data); ensure f.close; end

    success = system("#{editor} #{f.path}")
    raise "Unable to start editor" if !success
    begin return File.read(f.path); ensure f.unlink; end
  end
end
