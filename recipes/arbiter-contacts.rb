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

### Save content through run
node.run_state["shinken"]["arbiter"]["valid_contacts"] = []
node.run_state["shinken"]["arbiter"]["contacts"] = []

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

search(:users, "zenexity-internal:true") do |c|

  use_contacts = if c["admin"] == true
    if c["oncall"] == true
      ["oncall", "admin"]
    else
      ["admin"]
    end
  else
    ["generic-contact"]
  end


  if c["pager"] and c["oncall"] == true
    pager_number = case c["pager"]["country"]
    when "FR"
      "+33" + c["pager"]["number"]
    end
  else
    pager_number = nil
  end

  shinken_contact "#{c["id"]}-all" do
    register true

    contact_name "#{c["id"]}-all"
    contact_alias c["name"]
    pager pager_number unless pager_number.nil?
    email c["mail"]

    notificationways  ["sms", "email"]

    (c["shinken"]|| {}).delete_if{|k,v| k == "id"}.each_pair do |k,v|
      self.send k, v
    end

    use use_contacts + ["generic-contact-email-sms"]
  end

  shinken_contact "#{c["id"]}-sms" do
    register true
    contact_name "#{c["id"]}-sms"
    contact_alias c["name"]
    pager pager_number unless pager_number.nil?

    notificationways  ["sms"]

    (c["shinken"]|| {}).delete_if{|k,v| k == "id"}.each_pair do |k,v|
      self.send k, v
    end

    use use_contacts + ["generic-contact-sms"]
  end

  shinken_contact "#{c["id"]}-email" do
    register true

    contact_name "#{c["id"]}-email"
    contact_alias c["name"]
    email c["mail"]

    notificationways  ["email"]

    (c["shinken"]|| {}).delete_if{|k,v| k == "id"}.each_pair do |k,v|
      self.send k, v
    end


    use use_contacts + ["generic-contact-email"]
  end

  shinken_contact c["id"] do
    register true

    contact_name c["id"]
    contact_alias c["name"]

    (c["shinken"]|| {}).delete_if{|k,v| k == "id"}.each_pair do |k,v|
      self.send k, v
    end

    use use_contacts
  end
end



