action :create do

  template "shinken/arbiter/#{template? ? "templates/": ""}hostgroups/#{new_resource.hostgroup_key}" do
    path full_path
    source "definitions/hostgroups/hostgroup.cfg.erb"

    variables({
      :hostgroup_key   => new_resource.hostgroup_key,
      :hostgroup_name  => new_resource.hostgroup_name,
      :hostgroup_alias => new_resource.hostgroup_alias,
      :notes           => new_resource.notes,
      :notes_url       => new_resource.notes_url,
      :action_url      => new_resource.action_url,
      :realm           => new_resource.realm,

      :register        => new_resource.register,
      :use             => new_resource.use
    })

    action :create
    notifies :restart, "service[shinken-arbiter]", :delayed
  end

  node.run_state["shinken"]["arbiter"]["hostgroups"].push(path)
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
  paths = ["hostgroups", "#{new_resource.hostgroup_key}.cfg"]
  paths.unshift("templates") if not new_resource.register
  ::File.join(paths)
end

def full_path
  ::File.join("/etc/shinken/objects-chef", path)
end

def hostgroup_path
  paths = ["hostgroups", new_resource.hostgroup_key]
  paths.unshift("templates") if not new_resource.register
  ::File.join(paths)
end

def full_hostgroup_path
  ::File.join("/etc/shinken/objects-chef", hostgroup_path)
end
