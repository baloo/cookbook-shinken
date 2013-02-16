action :create do
  template "shinken/specific/daemon/#{new_resource.name}" do
    path full_path

    source "arbiter/daemon.cfg.erb"

    variables({
      "daemon_type" => new_resource.daemon_type,
      "variables"   => new_resource.variables,
      "address"     => new_resource.address,
      "port"        => new_resource.port,
      "name"        => new_resource.name
    })

    notifies :restart, "service[shinken-arbiter]", :delayed
    notifies :create, "template[shinken/arbiter/specific]", :delayed
  end

  node.run_state["shinken"]["arbiter"]["modules"].push(path)
end

action :delete do
  file "shinken/specific/daemon/#{new_resource.name}" do
    path full_path
    action :delete

    notifies :create, "template[shinken/arbiter/specific]", :delayed
  end
end

def path
  ::File.join("shinken-specific", "daemon", "#{new_resource.name}.cfg")
end

def full_path
  ::File.join("/etc/shinken", path)
end


