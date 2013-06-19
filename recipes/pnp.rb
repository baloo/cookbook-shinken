case node[:platform]
when "centos"
  include_recipe "yum::repoforge"
when  "debian"
  include_recipe "apt"
  apt_repository "backports" do
    uri "http://backports.debian.org/debian-backports"
    distribution "#{node['lsb']['codename']}-backports"
    components ["main"]
    action :add
  end
  apt_repository "dotdeb" do
    uri "http://packages.dotdeb.org/"
    distribution node['lsb']['codename']
    components ["all"]
    key "http://www.dotdeb.org/dotdeb.gpg"
    action :add
  end
end

package "pnp4nagios"
package node["shinken"]["pnp"]["fpm"]

service  node["shinken"]["pnp"]["fpm"] do
  action [:enable, :start]
end

service "npcd" do
  action [:enable, :start]
end

if node.has_key?("apache")
  template "#{node['apache']['dir']}/conf.d/pnp4nagios.conf" do
    mode 0644
    notifies :reload, "service[apache2]", :delayed
  end
end
