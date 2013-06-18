if node[:platform] == "centos"
  include_recipe "yum::repoforge"
end

package "pnp4nagios"
package "php-fpm"

service "php-fpm" do
  action [:enable, :start]
end

service "npcd" do
  action [:enable, :start]
end

template "#{node['apache']['dir']}/conf.d/pnp4nagios.conf" do
  mode 0644
  notifies :reload, "service[apache2]", :delayed
end
