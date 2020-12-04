module MiqAeMethodService
  module MiqAeServiceMiqQueue
    TASKS = []
    def initialize
      
    end
    def self.where(tracking_label: nil, class_name: nil)
      TASKS
    end
  end
  module MiqAeServiceUser
    USERS = [ OpenStruct.new(name: 'user name', userid: 'userid', current_group: OpenStruct.new(description: "Group1")) ]
    def initialize
      
    end
    def self.where(id: nil)
      USERS
    end
  end
end
MiqQueue = MiqAeMethodService::MiqAeMethodServiceMiqQueue

class TaskMock
  def initialize(data: {})
    @state_vars = data
    @object = Object.new
    def @object.save
      true
    end
    update_args()
  end

  def attributes=(data)
    @args = data[:args]
  end
  def deliver_on
    Time.new(2002, 10, 31, 2, 2, 2, "+02:00")
  end

  def update_args
    d = {
      object_type: 'TaskMock',
      object_id: '1234',
      namepace: 'namespace',
      class_name: 'class',
      instance_name: 'instance',
      state: 'StepName',
      ae_state_retries: '99',
      ae_state_data: @state_vars.to_yaml
    }
    @args = [ d ]
  end

  def tracking_label
    "r1234_#{@state_vars.keys.join(':')}"
  end

  def reload
    self
  end

  def args
    @args
  end

end
