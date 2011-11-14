# vim: ts=2 sw=2 expandtab foldmethod=marker:
#
# Cookbook Name:: monitoring
# Recipe:: first
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


# {{{ Services
services_directories = []

commands = {}

# Print every node matching the search pattern
search(:node, "monitoring_elements:*") do |matching_node|
  # Declare hosts
  template "/etc/shinken/objects/chef/hosts/#{matching_node.fqdn}.cfg" do
    source "host.cfg.erb"
    variables(
      :template => 'linux-server',
      :hostname => matching_node.fqdn,
      :address => matching_node.fqdn,
      :contact => 'admins'
    )
  end

  # Handle services
  directory "/etc/shinken/objects/chef/services/#{matching_node.fqdn}"
  services_directories.push("/etc/shinken/objects/chef/services/#{matching_node.fqdn}")

  matching_node.monitoring.elements.each do |element|
    service_files = []

    command = ([element[:nagios_cmd]] << element[:nagios_parameters])

    commands[command.hash] = command

    template "/etc/shinken/objects/chef/services/#{matching_node.fqdn}/#{element[:name]}.cfg" do
      source "service.cfg.erb"
      variables(
        :hostname => matching_node.fqdn,
        :nagios => command
      )
    end
    service_files.push("/etc/shinken/objects/chef/services/#{matching_node.fqdn}/#{element[:name]}.cfg")

    # Remove old files
    current_files = Dir.glob("/etc/shinken/objects/chef/services/#{matching_node.fqdn}/*.cfg")
    to_delete_files = current_files - service_files
    to_delete_files.each do |cfile|
      Chef::Log.info("Removing #{cfile} as it is not used anymore")
      file cfile do
        action :delete
      end
    end
  end
end

services_content = Dir.glob("/etc/shinken/objects/chef/services/*")
service_to_delete = services_content-services_directories
service_to_delete.each do |cdir|
  Chef::Log.info("Removing #{cdir} as it is not used anymore")
  if File.directory?(cdir)
    directory cdir do
      action :delete
      recursive true
    end
  else
    file cdir do
      action :delete
    end
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


