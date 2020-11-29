
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
        puts args.inspect
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
      @miq_queue_object.instance_variable_get(:@object).save
      reload()
      puts "Retries: #{@data[:ae_state_retries]} Next: #{@miq_queue_object.deliver_on}"
      puts "-"*50
      puts @data[:ae_state_data]
      puts "="*50
    end

    def get_state_var(key)
      reload()

      vars = YAML.load(@data[:ae_state_data])
      vars.fetch(key, "")
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