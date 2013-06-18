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


attribute :escalation_key,               :kind_of => String, :name_attribute => true

attribute :first_notification,           :kind_of => Integer
attribute :last_notification,            :kind_of => Integer
attribute :first_notification_time,      :kind_of => Integer
attribute :last_notification_time,       :kind_of => Integer

attribute :notification_interval,        :kind_of => Integer
attribute :escalation_period,             :kind_of => String
attribute :escalation_options,           :callbacks => validation_callback([:warning, :unknown, :critical, :recovery, :flapping, :scheduled])
attribute :contacts,                     :kind_of => Array
attribute :contact_groups,               :kind_of => Array

#attribute :register,                     :kind_of => [TrueClass, FalseClass], :default => true
#attribute :use,                          :kind_of => Array, :default => []


def initialize(*opts)
  super *opts
  @action = :create

#  @run_context.include_recipe "shinken::arbiter"
end
