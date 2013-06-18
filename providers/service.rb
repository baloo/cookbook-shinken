action :create do

  if not template?
    command = shinken_command "shinken/arbiter/services/#{new_resource.service_key}/command" do
      command_name new_resource.check_command
      command new_resource.command_line
      arguments new_resource.arguments
    end
    Chef::Log.info(command.command_identifier)
  end


  template "shinken/arbiter/#{template? ? "templates/": ""}services/#{new_resource.service_key}" do
    path full_path
    source "definitions/services/service.cfg.erb"
    mode 00644

    vars = {
      :service_key                  => new_resource.service_key,
      :host_name                    => new_resource.host_name,
      :hostgroup_name               => new_resource.hostgroup_name,
      :service_description          => new_resource.service_description,
      :display_name                 => new_resource.display_name,
      :servicegroups                => new_resource.servicegroups,
      :is_volatile                  => new_resource.is_volatile,
      :arguments                    => new_resource.arguments,
      :initial_state                => new_resource.initial_state,
      :max_check_attempts           => new_resource.max_check_attempts,
      :check_interval               => new_resource.check_interval,
      :retry_interval               => new_resource.retry_interval,
      :active_checks_enabled        => new_resource.active_checks_enabled,
      :passive_checks_enabled       => new_resource.passive_checks_enabled,
      :check_period                 => new_resource.check_period,
      :obsess_over_service          => new_resource.obsess_over_service,
      :check_freshness              => new_resource.check_freshness,
      :freshness_threshold          => new_resource.freshness_threshold,
      :event_handler                => new_resource.event_handler,
      :event_handler_enabled        => new_resource.event_handler_enabled,
      :low_flap_threshold           => new_resource.low_flap_threshold,
      :high_flap_threshold          => new_resource.high_flap_threshold,
      :flap_detection_enabled       => new_resource.flap_detection_enabled,
      :flap_detection_options       => new_resource.flap_detection_options,
      :process_perf_data            => new_resource.process_perf_data,
      :retain_status_information    => new_resource.retain_status_information,
      :retain_nonstatus_information => new_resource.retain_nonstatus_information,
      :notification_interval        => new_resource.notification_interval,
      :first_notification_delay     => new_resource.first_notification_delay,
      :notification_period          => new_resource.notification_period,
      :notification_options         => new_resource.notification_options,
      :notifications_enabled        => new_resource.notifications_enabled,
      :contacts                     => new_resource.contacts,
      :contact_groups               => new_resource.contact_groups,
      :stalking_options             => new_resource.stalking_options,
      :notes                        => new_resource.notes,
      :notes_url                    => new_resource.notes_url,
      :action_url                   => new_resource.action_url,
      :icon_image                   => new_resource.icon_image,
      :icon_image_alt               => new_resource.icon_image_alt,
      :escalations                  => new_resource.escalations,

      :register                     => new_resource.register,
      :use                          => ((not template?) ? ["base-service"]:[]) + new_resource.use
    }
    vars.update({
      :check_command                => command
    }) if not command.nil?

    
    variables(vars)

    action :create
    notifies :restart, "service[shinken-arbiter]", :delayed
  end

  node.run_state["shinken"]["arbiter"]["services"].push(path)
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
  paths = ["services"]
  paths.push(new_resource.host_name) if new_resource.host_name
  paths.push("#{new_resource.service_key}.cfg")
  paths.unshift("templates") if not new_resource.register
  ::File.join(paths)
end

def full_path
  ::File.join("/etc/shinken/objects-chef", path)
end
