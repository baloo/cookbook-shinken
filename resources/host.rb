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



attribute :host_key,                     :kind_of => String, :name_attribute => true
attribute :host_alias,                   :kind_of => String
attribute :host_name,                    :kind_of => String
attribute :display_name,                 :kind_of => String
attribute :address,                      :kind_of => String
attribute :parents,                      :kind_of => Array
attribute :hostgroups,                   :kind_of => Array
attribute :check_command,                :kind_of => String
attribute :initial_state,                :callbacks => validation_callback([:up, :down, :unreachable], false)
attribute :max_check_attempts,           :kind_of => Integer
attribute :check_interval,               :kind_of => Integer
attribute :retry_interval,               :kind_of => Integer
attribute :active_checks_enabled,        :kind_of => [TrueClass, FalseClass]
attribute :passive_checks_enabled,       :kind_of => [TrueClass, FalseClass]
attribute :check_period,                 :kind_of => String
attribute :obsess_over_host,             :kind_of => [TrueClass, FalseClass]
attribute :check_freshness,              :kind_of => [TrueClass, FalseClass]
attribute :freshness_threshold,          :kind_of => Integer
attribute :event_handler,                :kind_of => Integer
attribute :event_handler_enabled,        :kind_of => [TrueClass, FalseClass]
attribute :low_flap_threshold,           :kind_of => Integer
attribute :high_flap_threshold,          :kind_of => Integer
attribute :flap_detection_enabled,       :kind_of => [TrueClass, FalseClass]
attribute :flap_detection_options,       :callbacks => validation_callback([:up, :down, :unreachable])
attribute :process_perf_data,            :kind_of => [TrueClass, FalseClass]
attribute :retain_status_information,    :kind_of => [TrueClass, FalseClass]
attribute :retain_nonstatus_information, :kind_of => [TrueClass, FalseClass]
attribute :contacts,                     :kind_of => Array
attribute :contact_groups,               :kind_of => Array
attribute :notification_interval,        :kind_of => Integer
attribute :first_notification_delay,     :kind_of => Integer
attribute :notification_period,          :kind_of => String
attribute :notification_options,         :callbacks => validation_callback([:down, :unreachable, :recovery, :flapping, :scheduled])
attribute :notifications_enabled,        :kind_of => [TrueClass, FalseClass]
attribute :stalking_options,             :callbacks => validation_callback([:up, :down, :unreachable])
attribute :notes,                        :kind_of => String
attribute :notes_url,                    :kind_of => String
attribute :action_url,                   :kind_of => String
attribute :icon_image,                   :kind_of => String
attribute :icon_image_alt,               :kind_of => String
attribute :vrml_image,                   :kind_of => String
attribute :statusmap_image,              :kind_of => String
attribute :poller_tag,                   :kind_of => String
#attribute :2d_coords,                    x_coord,y_coord
#attribute :3d_coords,                    x_coord,y_coord,z_coord
attribute :escalations,                  :kind_of => String

attribute :register,                     :kind_of => [TrueClass, FalseClass], :default => true
attribute :use,                          :kind_of => Array


def initialize(*opts)
  super *opts
  @action = :create

  @run_context.include_recipe "shinken::arbiter-hosts"
end
