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
# We'll now populate hosts with real content
search(:node, "monitoring:*") do |n|
  # we'll use shinken_host LWRP to define host
  shinken_host n["fqdn"] do
    host_name n["fqdn"]
    address n["fqdn"]
    n["monitoring"]["host_definition"].each_pair do |k, v|
      self.send k, v
    end

    if n["monitoring"]["host_definition"]["use"].nil?
      use ["generic-host"]
    end
  end
end

# We'll now populate hosts with real content
search(:shinken_host_templates, "*:*") do |n|
  # we'll use shinken_host LWRP to define host
  shinken_host n["id"] do
    # We wont register templates
    register false

    n.delete_if{|k, v| k == "id"}.each_pair do |k, v|
      self.send k, v
    end

  end
end


