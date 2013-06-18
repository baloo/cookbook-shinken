action :create do

  template "shinken/arbiter/#{template? ? "templates/": ""}contacts/#{new_resource.contact_key}" do
    path full_path
    source "definitions/contacts/contact.cfg.erb"
    mode 00644

    variables({
      :contact_key                   => new_resource.contact_key,
      :contact_name                  => new_resource.contact_name,
      :contact_alias                 => new_resource.contact_alias,
      :contactgroups                 => new_resource.contactgroups,
      :host_notifications_enabled    => new_resource.host_notifications_enabled,
      :service_notifications_enabled => new_resource.service_notifications_enabled,
      :host_notification_period      => new_resource.host_notification_period,
      :service_notification_period   => new_resource.service_notification_period,
      :host_notification_options     => new_resource.host_notification_options,
      :service_notification_options  => new_resource.service_notification_options,
      :host_notification_commands    => new_resource.host_notification_commands,
      :service_notification_commands => new_resource.service_notification_commands,
      :min_business_impact           => new_resource.min_business_impact,
      :email                         => new_resource.email,
      :pager                         => new_resource.pager,
      :address1                      => new_resource.address1,
      :address2                      => new_resource.address2,
      :address3                      => new_resource.address3,
      :address4                      => new_resource.address4,
      :address5                      => new_resource.address5,
      :address6                      => new_resource.address6,
      :can_submit_commands           => new_resource.can_submit_commands,
      :is_admin                      => new_resource.is_admin,
      :retain_status_information     => new_resource.retain_status_information,
      :notificationways              => new_resource.notificationways,
      :password                      => new_resource.password,


      :register                      => new_resource.register,
      :use                           => new_resource.use
    })

    action :create
    notifies :restart, "service[shinken-arbiter]", :delayed
  end

  node.run_state["shinken"]["arbiter"]["contacts"].push(path)
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
  paths = ["contacts", "#{new_resource.contact_key}.cfg"]
  paths.unshift("templates") if not new_resource.register
  ::File.join(paths)
end

def full_path
  ::File.join("/etc/shinken/objects-chef", path)
end

def contact_path
  paths = ["contacts", new_resource.contact_key]
  paths.unshift("templates") if not new_resource.register
  ::File.join(paths)
end

def full_contact_path
  ::File.join("/etc/shinken/objects-chef", contact_path)
end
