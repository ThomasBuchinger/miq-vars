# frozen_string_literal: true

module MiqVar
  class Task
    attr_reader :data, :tracking_label

    def initialize(tracking_label)
      @tracking_label = tracking_label
      miq_queue = MiqQueue.where(tracking_label: tracking_label).first
      raise "Unable to find Task: #{@tracking_label}" if miq_queue.blank?
      
      @data = miq_queue.args.reduce({}, :merge).with_indifferent_access
    end

    def get_details()
      lines = []
      lines << "Task: #{@tracking_label}"
      lines << "  State: #{@data[:state]}: #{@data[:ae_state_retries]} Retriesi. Last at: #{@data[:ae_state_started]} (I have no idea what that timestamp actually is)"
      lines << "  User: #{@data[:user_id]}/#{@data[:miq_group_id]}"
      lines << "-"*50
      lines << @data[:ae_state_data]
      lines << "="*50
      lines
    end
  end
end
