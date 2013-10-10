#
# Cookbook Name:: shinken
# Recipe:: arbiter-contacts
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

## Contacts definition drop
# This recipe will drop contacts definitions and register them in a main file

### Include shinken-arbiter recipe
# See [shinken::arbiter](arbiter.html)

include_recipe "shinken::arbiter"

### Layout
#### Directories
#
# we'll use ``/etc/shinken/objects-chef/contacts`` and put subfiles in this 
directory "shinken/arbiter/contacts" do
  path "/etc/shinken/objects-chef/contacts"
end

directory "shinken/arbiter/templates/contacts" do
  path "/etc/shinken/objects-chef/templates/contacts"
end

directory "shinken/arbiter/contactgroups" do
  path "/etc/shinken/objects-chef/contactgroups"
end

### Save content through run
node.run_state["shinken"]["arbiter"]["contacts"] = []
node.run_state["shinken"]["arbiter"]["contactgroups"] = []
contactgroups = ["all"]

# We'll now populate contacts with real content
search(:shinken_contact_templates, "*:*") do |n|
  # we'll use shinken_host LWRP to define host
  shinken_contact n["id"] do
    # We wont register templates
    register false

    n.delete_if{|k, v| k == "id"}.each_pair do |k, v|
      self.send k, v
    end
  end
end

search(:shinken_contacts, "*:*") do |n|
  # we'll use shinken_host LWRP to define host
  shinken_contact n["id"] do

    contact_name n["id"]
    contact_alias n["comment"]
    email n["email"]
    contactgroups "#{n["groups"].join(',')}"
    n["groups"].each do |group|
      if !contactgroups.include?(group)
        contactgroups << group
      end
    end

    (n["shinken"]|| {}).delete_if{|k,v| k == "id"}.each_pair do |k,v|
      self.send k, v
    end

    if n.has_key?("use")
      use n["use"]
    else
      use ["generic-contact"]
    end
  end
end

search(:users, "nagios:* AND NOT action:remove") do |c|
  shinken_contact c["id"] do
    register true

    contact_name c["id"]
    contact_alias c["comment"]
    email c["nagios"]["email"]
    pager c["nagios"]["pager"] if c["nagios"].has_key?("pager")

    contactgroups "#{c["groups"].join(',')}"
    c["groups"].each do |group|
      if !contactgroups.include?(group)
        contactgroups << group
      end
    end

    (c["shinken"]|| {}).delete_if{|k,v| k == "id"}.each_pair do |k,v|
      self.send k, v
    end

    if c["groups"].include?("sysadmin")
      if c["oncall"] == true
        use ["oncall", "admin"]
      else
        use ["admin"]
      end
    else
      use ["generic-contact"]
    end
  end
end

contactgroups.each do |group|
  shinken_contactgroup group do
    contactgroup_name group
    contactgroup_alias group
  end
end
