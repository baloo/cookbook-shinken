action :create do

  template "shinken/arbiter/#{template? ? "templates/": ""}hosts/#{new_resource.host_key}" do
    path full_path
    source "definitions/hosts/host.cfg.erb"
    mode 00644

    variables({
      :host_key                              => new_resource.host_key,
      :host_name                             => new_resource.host_name,
      :host_alias                            => new_resource.host_alias,
      :display_name                          => new_resource.display_name,
      :address                               => new_resource.address,
      :hostgroups                            => new_resource.hostgroups,
      :check_command                         => new_resource.check_command,
      :register                              => new_resource.register,

      :max_check_attempts                    => new_resource.max_check_attempts,
      :check_interval                        => new_resource.check_interval,
      :active_checks_enabled                 => new_resource.active_checks_enabled,
      :check_period                          => new_resource.check_period,
      :contacts                              => new_resource.contacts,
      :contact_groups                        => new_resource.contact_groups,
      :notification_interval                 => new_resource.notification_interval,
      :notification_period                   => new_resource.notification_period,
      :notification_options                  => new_resource.notification_options,
      :notifications_enabled                 => new_resource.notifications_enabled,
      :event_handler_enabled                 => new_resource.event_handler_enabled,
      :flap_detection_enabled                => new_resource.flap_detection_enabled,
      :process_perf_data                     => new_resource.process_perf_data,
      :notes                                 => new_resource.notes,
      :notes_url                             => new_resource.notes_url,
      :action_url                            => new_resource.action_url,
      :icon_image                            => new_resource.icon_image,
      :icon_image_alt                        => new_resource.icon_image_alt,

      :use                                   => new_resource.use
    })

    action :create
    notifies :restart, "service[shinken-arbiter]", :delayed
  end

  if not template?
    directory "shinken/arbiter/hosts/#{new_resource.host_name}" do
      path full_host_path
      action :create
    end
  end

  node.run_state["shinken"]["arbiter"]["hosts"].push(path)
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
  paths = ["hosts", "#{new_resource.host_key}.cfg"]
  paths.unshift("templates") if not new_resource.register
  ::File.join(paths)
end

def full_path
  ::File.join("/etc/shinken/objects-chef", path)
end

def host_path
  paths = ["services", new_resource.host_key]
  paths.unshift("templates") if not new_resource.register
  ::File.join(paths)
end

def full_host_path
  ::File.join("/etc/shinken/objects-chef", host_path)
end
