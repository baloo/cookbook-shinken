### Include base recipe
# See [shinken::broker](broker.html)
include_recipe "shinken::broker"

major = node['platform_version'].to_i
machine = node['kernel']['machine']
platform_family = node['platform_family']
thruk_version = "1.68"

include_recipe "apache2"
include_recipe "apache2::mod_rewrite"
include_recipe "apache2::mod_php5"
include_recipe "apache2::mod_fcgid"
include_recipe "apache2::mod_ssl"

apache_site "000-default" do
  enable false
end

remote_file "#{Chef::Config[:file_cache_path]}/thruk-#{thruk_version}-1.#{platform_family}#{major}.#{machine}.rpm" do
  action :create_if_missing
  source "http://www.thruk.org/files/pkg/v#{thruk_version}/#{platform_family}#{major}/#{machine}/thruk-#{thruk_version}-1.#{platform_family}#{major}.#{machine}.rpm"
  backup false
  not_if "rpm -qa | grep -q '^thruk-#{thruk_version}'"
  notifies :install, "rpm_package[thruk]", :immediately
end

rpm_package "thruk" do
  source "#{Chef::Config[:file_cache_path]}/thruk-#{thruk_version}-1.#{platform_family}#{major}.#{machine}.rpm"
  options "--nodeps"
  action :nothing
end

file "thruk-cleanup" do
  path "#{Chef::Config[:file_cache_path]}/thruk-#{thruk_version}-1.#{platform_family}#{major}.#{machine}.rpm"
  action :delete
end


remote_directory "/usr/share/thruk/root/thruk/icons" do
  mode 0755
end

cookbook_file "/etc/thruk/thruk_local.conf" do
  mode 0644
end

file "#{node['apache']['dir']}/conf.d/thruk.conf" do
  action :delete
  notifies :reload, "service[apache2]", :delayed
end

cookbook_file "#{node['apache']['dir']}/ssl/#{node['shinken']['cert_name']}.crt" do
  source "certs/#{node['shinken']['cert_name']}.crt"
end

cookbook_file "#{node['apache']['dir']}/ssl/#{node['shinken']['cert_name']}.key" do
  source "certs/#{node['shinken']['cert_name']}.key"
end

if !node['shinken']['cert_ca_name'].nil?
  cookbook_file "#{node['apache']['dir']}/ssl/#{node['shinken']['cert_ca_name']}.crt" do
    source "certs/#{node['shinken']['cert_ca_name']}.crt"
  end
end

template "#{node['apache']['dir']}/sites-available/thruk.conf" do
  source "thruk-apache2.conf.erb"
  mode 00644
  if ::File.symlink?("#{node['apache']['dir']}/sites-enabled/thruk.conf")
    notifies :reload, "service[apache2]", :immediately
  end
end

template "/etc/thruk/cgi.cfg" do
  mode 0644
  notifies :restart, "service[apache2]", :delayed
end

apache_site "thruk.conf"

service "thruk" do
  action [:enable, :start]
  subscribes :restart, "cookbook_file[/etc/thruk/thruk_local.conf]", :immediately
end

