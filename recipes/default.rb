# vim: ts=2 sw=2 expandtab foldmethod=marker:
#
# Cookbook Name:: shinken
# Recipe:: default
#
# Author:: Arthur Gautier <aga@zenexity.com>
# Copyright 2011, Zenexity, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#





package "shinken"

directory "/etc/shinken/objects/chef/"

%w{services hosts contacts commands contactgroups}.each do |dir|
  directory "/etc/shinken/objects/chef/#{dir}"
end

# {{{ Templates
directory "/etc/shinken/objects/chef/templates"

# {{{ Host templates
remote_directory "/etc/shinken/objects/chef/templates/hosts" do
  source   "templates/hosts"
  cookbook "shinken"
  purge    true
end
# }}}

# {{{ Services templates
remote_directory "/etc/shinken/objects/chef/templates/services" do
  source   "templates/services"
  cookbook "shinken"
  purge    true
end
# }}}


# {{{ Timeperiod templates
remote_directory "/etc/shinken/objects/chef/templates/timeperiods" do
  source   "templates/timeperiods"
  cookbook "shinken"
  purge    true
end
# }}}

# {{{ Contact templates
remote_directory "/etc/shinken/objects/chef/templates/contacts" do
  source   "templates/contacts"
  cookbook "shinken"
  purge    true
end
# }}}
# }}}


# {{{ Services
services_directories = []

commands = {}

environments = [
  'production',
  'preproduction',
  'development',
  'test']

overrides = [
  "max_check_attempts"
  ]

# Print every node matching the search pattern
search(:node, "monitoring_elements:*") do |matching_node|
  monitoring = matching_node[:monitoring] || Mash.new
  services_overrides = (monitoring[:overrides] || Mash.new).to_hash.reject{|k,v|
    overrides.index(k).nil?
  }
  contacts = monitoring[:contacts] || []

  if monitoring["disable"] == true
    # If disable, just continue to next one
    next
  end

  # Filter environment
  environment = monitoring[:environment]
  if not environments.index(environment)
    environment = 'production'
  end

  # Handle hostname
  hostname = matching_node.fqdn
  if matching_node["cloud"] && matching_node["cloud"]["public_hostname"]
    hostname = matching_node["cloud"]["public_hostname"]
  end
  if matching_node["monitoring"] && matching_node["monitoring"]["hostname"]
    hostname = matching_node["monitoring"]["hostname"]
  end


  # Declare hosts
  template "/etc/shinken/objects/chef/hosts/#{hostname}.cfg" do
    source "host.cfg.erb"
    variables(
      :templates => ['tmpl-env-'+ environment, 'tmpl-os-linux'],
      :hostname => hostname,
      :address => hostname,
      :contact_groups => ['zenexity-sysadmins'],
      :contacts => contacts
    )
  end

  # Handle services
  directory "/etc/shinken/objects/chef/services/#{hostname}"
  services_directories.push("/etc/shinken/objects/chef/services/#{hostname}")

  matching_node.monitoring.elements.each do |element|
    service_files = []

    command = ([element[:nagios_cmd]] << element[:nagios_parameters])

    commands[command.hash] = command

    template "/etc/shinken/objects/chef/services/#{hostname}/#{element[:name]}.cfg" do

      source "service.cfg.erb"

      variables(
        :templates   => ['tmpl-env-'+ environment, 'tmpl-generic'],
        :hostname    => hostname,
        :overrides   => services_overrides,
        :nagios      => command,
        :description => element["description"] || command.first
      )
    end
    service_files.push("/etc/shinken/objects/chef/services/#{hostname}/#{element[:name]}.cfg")

    # Remove old files
    current_files = Dir.glob("/etc/shinken/objects/chef/services/#{hostname}/*.cfg")
    to_delete_files = current_files - service_files
    to_delete_files.each do |cfile|
      Chef::Log.info("Removing #{cfile} as it is not used anymore")
      #file cfile do
      #  action :delete
      #end
    end
  end
end

services_content = Dir.glob("/etc/shinken/objects/chef/services/*")
service_to_delete = services_content-services_directories
service_to_delete.each do |cdir|
  Chef::Log.info("Removing #{cdir} as it is not used anymore")
  if File.directory?(cdir)
    #directory cdir do
    #  action :delete
    #  recursive true
    #end
  else
    #file cdir do
    #  action :delete
    #end
  end
end
# }}}


# {{{ Commands
commands.each do |command_name, command|
  template "/etc/shinken/objects/chef/commands/#{command.first}#{command.hash}.cfg" do
    source "command.cfg.erb"
    variables(
      :nagios => command
    )
  end
end
# }}}


# {{{ Contacts
users = search(:users, "*:*")
users.each do |user|
  template "/etc/shinken/objects/chef/contacts/#{user.id}.cfg" do
    source "contact.cfg.erb"
    variables(
      :user => user
    )
  end
end
# }}}

# Handle contactgroups
cgroups = search(:shinken_contact_groups, "*:*")
cgroups.each do |cgroup|
  template "/etc/shinken/objects/chef/contactgroups/#{cgroup.id}.cfg" do
    source "contactgroup.cfg.erb"
    variables(
      :cgroup => cgroup
    )
  end
end


