action :create do

  template "shinken/arbiter/#{template? ? "templates/": ""}contactgroups/#{new_resource.contactgroup_key}" do
    path full_path
    source "definitions/contactgroups/contactgroup.cfg.erb"

    variables({
      :contactgroup_key              => new_resource.contactgroup_key,
      :contactgroup_name             => new_resource.contactgroup_name,
      :contactgroup_alias            => new_resource.contactgroup_alias,
      :contactgroup_members          => new_resource.contactgroup_members,
      :members                       => new_resource.members,

      :register                      => new_resource.register,
      :use                           => new_resource.use
    })

    action :create
    notifies :restart, "service[shinken-arbiter]", :delayed
  end

  node.run_state["shinken"]["arbiter"]["contactgroups"].push(path)
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
  paths = ["contactgroups", "#{new_resource.contactgroup_key}.cfg"]
  paths.unshift("templates") if not new_resource.register
  ::File.join(paths)
end

def full_path
  ::File.join("/etc/shinken/objects-chef", path)
end

def contactgroup_path
  paths = ["contactgroups", new_resource.contactgroup_key]
  paths.unshift("templates") if not new_resource.register
  ::File.join(paths)
end

def full_contactgroup_path
  ::File.join("/etc/shinken/objects-chef", contactgroup_path)
end
