action :create do

  template "shinken/arbiter/#{template? ? "templates/": ""}servicegroups/#{new_resource.servicegroup_key}" do
    path full_path
    source "definitions/servicegroups/servicegroup.cfg.erb"

    variables({
      :servicegroup_key   => new_resource.servicegroup_key,
      :servicegroup_name  => new_resource.servicegroup_name,
      :servicegroup_alias => new_resource.servicegroup_alias,
      :notes              => new_resource.notes,
      :notes_url          => new_resource.notes_url,

      :register           => new_resource.register,
      :use                => new_resource.use
    })

    action :create
    notifies :restart, "service[shinken-arbiter]", :delayed
  end

  node.run_state["shinken"]["arbiter"]["servicegroups"].push(path)
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
  paths = ["servicegroups", "#{new_resource.servicegroup_key}.cfg"]
  paths.unshift("templates") if not new_resource.register
  ::File.join(paths)
end

def full_path
  ::File.join("/etc/shinken/objects-chef", path)
end

def servicegroup_path
  paths = ["servicegroups", new_resource.servicegroup_key]
  paths.unshift("templates") if not new_resource.register
  ::File.join(paths)
end

def full_servicegroup_path
  ::File.join("/etc/shinken/objects-chef", servicegroup_path)
end
