actions :create, :delete

def self.validation_callback(items, combination = true)
  if combination
    {
      "is not a valid combination" => Proc.new {|ts|
        returns = ts.map do |t|
          items.include?(t.to_sym) 
        end
        not returns.include?(false)
      }
    }
  else
    {
      "is not a valid type" => Proc.new {|ts|
        items.include?(ts.to_sym)
      }
    }
  end
end



attribute :notificationway_name,            :kind_of => String, :name_attribute => true
attribute :host_notifications_enabled,      :kind_of => [TrueClass, FalseClass]
attribute :service_notifications_enabled,   :kind_of => [TrueClass, FalseClass]
attribute :host_notification_period,        :kind_of => String
attribute :service_notification_period,     :kind_of => String
attribute :host_notification_options,       :callbacks => validation_callback([:down, :unreachable,:recovery, :flapping, :scheduled])
attribute :service_notification_options,    :callbacks => validation_callback([:warning, :unknown, :critical, :recovery, :flapping, :scheduled])
attribute :host_notification_commands,      :kind_of => String
attribute :service_notification_commands,   :kind_of => String
attribute :min_business_impact,             :kind_of => Integer

attribute :register,                        :kind_of => [TrueClass, FalseClass], :default => true
attribute :use,                             :kind_of => Array


def initialize(*opts)
  super *opts
  @action = :create

  @run_context.include_recipe "shinken::arbiter-notificationways"
end
