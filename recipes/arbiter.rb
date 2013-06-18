#
# Cookbook Name:: shinken
# Recipe:: arbiter
#
# Copyright 2013, Arthur Gautier
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

## Shinken arbiter install
# Arbiter is the configuration storage and dispatch node in a shinken install

### Include base recipe
# See [shinken::base](base.html)

include_recipe "shinken::base"

### Package install

package "shinken-arbiter"

### Layout
#### Directories

directory "shinken/arbiter/specific" do
  path "/etc/shinken/shinken-specific"
end

directory "shinken/arbiter/specific/daemon" do
  path "/etc/shinken/shinken-specific/daemon"
end

directory "shinken/arbiter/specific/module" do
  path "/etc/shinken/shinken-specific/module"
end


### Daemons and modules
# We'll now drop shinken daemon configuration along with modules for them
#
# For this, daemons will be dropped, at last [main file](#section-Generate_shinken-specific_with_daemons_and_modules)
# will be regenerated to include each individual files.
#
# Each daemons and modules will drop it's file and will register in run_state
# list. This list will be used after to generate the main file.

node.run_state["shinken"]["arbiter"] = {}
node.run_state["shinken"]["arbiter"]["modules"] = []

#### Daemons configuration
# For each daemons, we will search in chef's database. We will search for
# ``shinken::foo`` recipe in each nodes.

[:arbiter, 
 :broker,
 :poller,
 :reactionner,
 :scheduler,
 :receiver].each do |daemon|
  search(:node, "recipes:shinken\\:\\:#{daemon}") do |n|

    # And we'll then use lwrp shinken_daemon for configuration of this daemon
    shinken_daemon "#{daemon}-#{n[:fqdn]}" do
      daemon_type daemon

      address n["fqdn"]
      port n["shinken"][daemon.to_s]["port"]

      variables n["shinken"][daemon.to_s]["variables"]
      modules   n["shinken"][daemon.to_s]["modules"]
    end

  end
end

#### Shinken modules
# Basic modules are defined in data bag shinken_modules. We'l then search for
# them and then generate subsequent files and register against main
# configuration file
search(:shinken_modules, "id:*") do |mod|

  # We'll now use lwrp shinken_module which will create files and register them
  shinken_module mod["id"] do
    module_type mod["type"].to_sym

    variables   mod["variables"]
    modules     mod["modules"] || []
  end
end

#### Generate shinken-specific with daemons and modules
# Main configuration for daemons and modules
# We will include daemon and modules files

template "shinken/arbiter/specific" do
  path "/etc/shinken/shinken-specific.cfg"
  source "arbiter/shinken-specific.cfg.erb"

  variables({
    :modules => node.run_state["shinken"]["arbiter"]["modules"]
  })

  notifies :restart, "service[shinken-arbiter]", :delayed
end

### Definitions
directory "shinken/arbiter/definitions" do
  path "/etc/shinken/objects-chef"
end

directory "shinken/arbiter/definitions/templates" do
  path "/etc/shinken/objects-chef/templates"
end

# We'll load definitions in sub recipes
include_recipe "shinken::arbiter-timeperiods"
include_recipe "shinken::arbiter-commands"
include_recipe "shinken::arbiter-notificationways"
include_recipe "shinken::arbiter-contacts"
include_recipe "shinken::arbiter-hostgroups"
include_recipe "shinken::arbiter-hosts"
include_recipe "shinken::arbiter-servicegroups"
include_recipe "shinken::arbiter-services"
include_recipe "shinken::arbiter-escalations"

#### Main configuration file

template "shinken/arbiter/ini" do
  path "/etc/shinken/nagios.cfg"
  source "arbiter/arbiter.cfg.erb"

  variables({
    :service_files => node.run_state["shinken"]["arbiter"]["services"],
    :servicegroup_files => node.run_state["shinken"]["arbiter"]["servicegroups"],
    :host_files => node.run_state["shinken"]["arbiter"]["hosts"],
    :hostgroup_files => node.run_state["shinken"]["arbiter"]["hostgroups"],
    :command_files => node.run_state["shinken"]["arbiter"]["commands"],
    :contact_files => node.run_state["shinken"]["arbiter"]["contacts"],
    :timeperiod_files => node.run_state["shinken"]["arbiter"]["timeperiods"],
    :escalation_files => node.run_state["shinken"]["arbiter"]["escalations"],
    :notiticationway_files => node.run_state["shinken"]["arbiter"]["notificationways"]
  })


  notifies :restart, "service[shinken-arbiter]", :delayed
end

if node[:platform] == "centos"
  cookbook_file "/etc/init.d/shinken-arbiter" do
    mode "0755"
  end
end

### Service stuff
# Declare arbiter service
service "shinken-arbiter" do
  # Ensure it is started by default and running
  action [:enable, :start]
  ignore_failure true

  # If ``/etc/default/shinken`` is changed, we'll restart
  subscribes :restart, "template[shinken/default/debian]", :delayed
end


