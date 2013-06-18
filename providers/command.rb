action :create do
  template "shinken/arbiter/commands/#{new_resource.command_identifier}" do
    path full_path
    source "definitions/commands/command.cfg.erb"
    mode 00644

    variables({
      :command_name => new_resource.command_identifier,
      :command_line => ([new_resource.command] + new_resource.arguments)
    })

    action :create
    notifies :restart, "service[shinken-arbiter]", :delayed
  end

  node.run_state["shinken"]["arbiter"]["commands"].push(path)
end

action :delete do
  file "shinken/arbiter/commands/#{new_resource.command_identifier}" do
    action :delete
  end
end

def path
  ::File.join("commands", "#{new_resource.command_identifier}.cfg")
end

def full_path
  ::File.join("/etc/shinken/objects-chef", path)
end

