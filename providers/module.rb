action :create do
  template "shinken/specific/module/#{new_resource.name}" do
    path full_path
    source "arbiter/module.cfg.erb"
    mode 00644

    variables({
      "module_type" => new_resource.module_type,
      "variables"   => new_resource.variables,
      "modules"     => new_resource.modules,
      "name"        => new_resource.name
    })

    notifies :restart, "service[shinken-arbiter]", :delayed
    notifies :create, "template[shinken/arbiter/specific]", :delayed
  end

  node.run_state["shinken"]["arbiter"]["modules"].push(path)
end

action :delete do
  file "shinken/specific/module/#{new_resource.name}" do
    path full_path
    action :delete

    notifies :restart, "service[shinken-arbiter]", :delayed
    notifies :create, "template[shinken/arbiter/specific]", :delayed
  end
end

def path
  ::File.join("shinken-specific", "module", "#{new_resource.name}.cfg")
end

def full_path
  ::File.join("/etc/shinken", path)
end


