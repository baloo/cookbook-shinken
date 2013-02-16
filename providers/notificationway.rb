action :create do

  template "shinken/arbiter/#{template? ? "templates/": ""}notificationway/#{new_resource.notificationway_name}" do
    path full_path
    source "definitions/notificationways/notificationway.cfg.erb"

    variables({
      :notificationway_name          => new_resource.notificationway_name,
      :host_notifications_enabled    => new_resource.host_notifications_enabled,
      :service_notifications_enabled => new_resource.service_notifications_enabled,
      :host_notification_period      => new_resource.host_notification_period,
      :service_notification_period   => new_resource.service_notification_period,
      :host_notification_options     => new_resource.host_notification_options,
      :service_notification_options  => new_resource.service_notification_options,
      :host_notification_commands    => new_resource.host_notification_commands,
      :service_notification_commands => new_resource.service_notification_commands,
      :min_business_impact           => new_resource.min_business_impact,

      :register                      => new_resource.register,
      :use                           => new_resource.use
    })

    action :create
    notifies :restart, "service[shinken-arbiter]", :delayed
  end

  node.run_state["shinken"]["arbiter"]["notificationways"].push(path)
end

action :delete do
  file full_path do
    action :delete
  end
end

def template?
  not new_resource.register
end

def path
  paths = ["notificationways", "#{new_resource.notificationway_name}.cfg"]
  paths.unshift("templates") if not new_resource.register
  ::File.join(paths)
end

def full_path
  ::File.join("/etc/shinken/objects-chef", path)
end

def notificationway_path
  paths = ["notificationways", new_resource.notificationway_name]
  paths.unshift("templates") if not new_resource.register
  ::File.join(paths)
end

def full_notificationway_path
  ::File.join("/etc/shinken/objects-chef", notificationway_path)
end
