actions :create, :delete

attribute :contact_key,                   :kind_of => String, :name_attribute => true
attribute :contact_alias,                 :kind_of => String
attribute :contact_name,                  :kind_of => String
attribute :contactgroups,                 :kind_of => String
attribute :host_notifications_enabled,    :kind_of => [TrueClass, FalseClass]
attribute :service_notifications_enabled, :kind_of => [TrueClass, FalseClass]
attribute :host_notification_period,      :kind_of => String
attribute :service_notification_period,   :kind_of => String
attribute :host_notification_options,     :kind_of => String
attribute :service_notification_options,  :kind_of => String
attribute :host_notification_commands,    :kind_of => String
attribute :service_notification_commands, :kind_of => String
attribute :min_business_impact,           :kind_of => Integer
attribute :email,                         :kind_of => String
attribute :pager,                         :kind_of => String
attribute :address1,                      :kind_of => String
attribute :address2,                      :kind_of => String
attribute :address3,                      :kind_of => String
attribute :address4,                      :kind_of => String
attribute :address5,                      :kind_of => String
attribute :address6,                      :kind_of => String
attribute :can_submit_commands,           :kind_of => [TrueClass, FalseClass]
attribute :is_admin,                      :kind_of => [TrueClass, FalseClass]
attribute :retain_status_information,     :kind_of => [TrueClass, FalseClass]
attribute :notificationways,              :kind_of => Array
attribute :password,                      :kind_of => String


attribute :register,                      :kind_of => [TrueClass, FalseClass], :default => true
attribute :use,                           :kind_of => Array


def initialize(*opts)
  super *opts
  @action = :create

  @run_context.include_recipe "shinken::arbiter-contacts"
end

