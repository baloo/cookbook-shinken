action :create do

  # if not template?
  #   command = shinken_command "shinken/arbiter/escalations/#{new_resource.escalation_key}/command" do
  #     command_name new_resource.check_command
  #     command new_resource.command_line
  #     arguments new_resource.arguments
  #   end
  #   Chef::Log.info(command.command_identifier)
  # end


  template "shinken/arbiter/escalations/#{new_resource.escalation_key}" do
    path full_path
    source "definitions/escalations/escalation.cfg.erb"
    mode 00644

    vars = {
      :escalation_key               => new_resource.escalation_key,

      :first_notification           => new_resource.first_notification,
      :last_notification            => new_resource.last_notification,
      :first_notification_time      => new_resource.first_notification_time,
      :last_notification_time       => new_resource.last_notification_time,

      :notification_interval        => new_resource.notification_interval,
      :escalation_period            => new_resource.escalation_period,
      :escalation_options           => new_resource.escalation_options,
      :contacts                     => new_resource.contacts,
      :contact_groups               => new_resource.contact_groups#,

#      :register                     => new_resource.register,
#      :use                          => new_resource.use
    }
#    vars.update({
#      :check_command                => command
#    }) if not command.nil?

    
    variables(vars)

    action :create
    notifies :restart, "service[shinken-arbiter]", :delayed
  end

  node.run_state["shinken"]["arbiter"]["escalations"].push(path)
end

action :delete do
  file full_path do
    action :delete
  end
end

#def template?
#  not new_resource.register
#end

def path
  ::File.join("escalations", "#{new_resource.escalation_key}.cfg")
#  paths = ["escalations"]
#  paths.push(new_resource.host_name) if new_resource.host_name
#  paths.push("#{new_resource.escalation_key}.cfg")
#  paths.unshift("templates") if not new_resource.register
#  ::File.join(paths)
end

def full_path
  ::File.join("/etc/shinken/objects-chef", path)
end
