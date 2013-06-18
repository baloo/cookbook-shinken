#
# Cookbook Name:: shinken
# Recipe:: arbiter-hosts
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

## Hosts definition drop
# This recipe will drop hosts definitions and register them in a main file

### Include shinken-arbiter recipe
# See [shinken::arbiter](arbiter.html)

include_recipe "shinken::arbiter"

### Layout
#### Directories
#
# we'll use ``/etc/shinken/objects-chef/hosts`` and put subfiles in this 
directory "shinken/arbiter/hosts" do
  path "/etc/shinken/objects-chef/hosts"
end

directory "shinken/arbiter/hosts/services" do
  path "/etc/shinken/objects-chef/services"
end

directory "shinken/arbiter/templates/hosts" do
  path "/etc/shinken/objects-chef/templates/hosts"
end

### Save content through run
node.run_state["shinken"]["arbiter"]["hosts"] = []

### Populate
# Templates first
host_templates = search(:shinken_host_templates, "*:*") 
host_templates.sort! {|a,b| a.name <=> b.name }

host_templates.each do |n|
  # we'll use shinken_host LWRP to define host
  shinken_host n["id"] do
    # We wont register templates
    register false

    n.delete_if{|k, v| k == "id"}.each_pair do |k, v|
      self.send k, v
    end

  end
end

# sort the hosts to prevent extra reloads
nodes = search(:node, "roles:monitoring")
nodes.sort! {|a,b| a.name <=> b.name }

# We'll now populate hosts with real content
nodes.each do |n|
  # we'll use shinken_host LWRP to define host
  shinken_host n["hostname"] do
    host_name n["hostname"]
    address n["ipaddress"]
    host_alias n["fqdn"]
    hostgroups ["+#{n['os']}",n['roles'].join(",")]

    # setup automatic poller tags
    if node["shinken"]["auto_poller_tags"]
      poller_tag n["domain"]
    end

    (n["nagios"]["host_definition"]||{}).each_pair do |k, v|
      self.send k, v
    end

    if (n["nagios"]["host_definition"]|| {})["use"].nil?
      use ["#{n['platform']}-host"]
    end
  end
end

# add the manual hosts
hosts = search(:shinken_hosts, "*:*") 
hosts.sort! {|a,b| a.name <=> b.name }

hosts.each do |n|
  # we'll use shinken_host LWRP to define host
  shinken_host n["host_name"] do
    n.delete_if{|k, v| k == "id"}.each_pair do |k, v|
      self.send k, v
    end
  end
end
