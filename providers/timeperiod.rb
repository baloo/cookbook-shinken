action :create do

  template "shinken/arbiter/#{template? ? "templates/": ""}timeperiods/#{new_resource.timeperiod_key}" do
    path full_path
    source "definitions/timeperiods/timeperiod.cfg.erb"

    variables({
      :timeperiod_key    => new_resource.timeperiod_key,
      :timeperiod_alias  => new_resource.timeperiod_alias,
      :timeperiod_name   => new_resource.timeperiod_name,
      :exclude           => new_resource.exclude,
      :content           => new_resource.content,

      :register          => new_resource.register,
      :use               => new_resource.use
    })

    action :create
    notifies :restart, "service[shinken-arbiter]", :delayed
  end

  node.run_state["shinken"]["arbiter"]["timeperiods"].push(path)
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
  paths = ["timeperiods", "#{new_resource.timeperiod_key}.cfg"]
  paths.unshift("templates") if not new_resource.register
  ::File.join(paths)
end

def full_path
  ::File.join("/etc/shinken/objects-chef", path)
end

def timeperiod_path
  paths = ["timeperiods", new_resource.timeperiod_key]
  paths.unshift("templates") if not new_resource.register
  ::File.join(paths)
end

def full_timeperiod_path
  ::File.join("/etc/shinken/objects-chef", timeperiod_path)
end
