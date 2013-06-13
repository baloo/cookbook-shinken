action :create do

  template "shinken/arbiter/#{template? ? "templates/": ""}service_dependency/#{new_resource.key}" do
    path full_path
    source "definitions/service-dependencies/service-dependency.cfg.erb"

    variables({
      :key                            => new_resource.key,
      :hostname                       => new_resource.hostname,
      :service_description            => new_resource.service_description,
      :dependent_hostname             => new_resource.dependent_hostname,
      :dependent_service_description  => new_resource.dependent_service_description,

      :register                       => new_resource.register,
      :use                            => new_resource.use
    })

    action :create
    notifies :restart, "service[shinken-arbiter]", :delayed
  end

  node.run_state["shinken"]["arbiter"]["service-dependencies"].push(path)
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
  paths = ["service-dependencies", "#{new_resource.key.gsub(/[^a-z0-9\.-]/, '')}.cfg"]
  paths.unshift("templates") if not new_resource.register
  ::File.join(paths)
end

def full_path
  ::File.join("/etc/shinken/objects-chef", path)
end

def servicegroup_path
  paths = ["service-dependencies", new_resource.key]
  paths.unshift("templates") if not new_resource.register
  ::File.join(paths)
end

def full_servicegroup_path
  ::File.join("/etc/shinken/objects-chef", servicegroup_path)
end
