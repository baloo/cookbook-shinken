#
# Cookbook Name:: shinken
# Recipe:: broker
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

## Shinken broker install
# Broker is the configuration storage and dispatch node in a shinken install

### Include base recipe
# See [shinken::base](base.html)

include_recipe "shinken::base"
### Package install
# For now we only handle debian packages

package "shinken-broker"

### Service stuff
if node[:platform] == "centos"
  cookbook_file "/etc/init.d/shinken-broker" do
    mode "0755"
  end
end

# Declare broker service
service "shinken-broker" do
  # Ensure it is started by default and running
  action [:enable, :start]

  # If ``/etc/default/shinken`` is changed, we'll restart
  subscribes :restart, "template[shinken/default/debian]", :delayed
end

### Configuration files
template "shinken/broker/ini" do
  path "/etc/shinken/brokerd.ini"
  source "broker/brokerd.ini.erb"
end


