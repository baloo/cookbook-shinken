#
# Cookbook Name:: shinken
# Recipe:: broker-webui
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

## Shinken broker-webui install
# Webui is a builtin web interface in shinken

### Include base recipe
# See [shinken::broker](broker.html)
include_recipe "shinken::broker"

### Package install
# For now we only handle debian packages
if node['platform_family'] == "debian"
  package "shinken-webui"
end

### Webui module declaration
# Store in db
node.default["shinken"]["broker"]["modules"]["webui"] = {
  "id" =>   "webui",
  "modules" => [
    "apache-passwd"
  ],
  "type" => "webui",
  "variables" => {
    "allow_html_output" => 0,
    "auth_secret" =>       "c4c70386a4959a91e3725583f6ce75b40c67e70b1bf144fd49bc6b63f50c33f7",
    "host" =>              "127.0.0.1",
    "manage_acl" =>        1,
    "max_output_length" => 100,
    "play_sound" =>        0,
    "port" =>              7767
  }
}

# Declare module in broker
# We'll need to merge with existing modules
# Proc is here just for namespacing code
node.override["shinken"]["broker"]["variables"]["modules"] = Proc.new{
  elts = node.normal["shinken"]["broker"]["variables"]["modules"].split(",").map{|s| s.strip()}
  elts.push("webui")
  elts.uniq!
  elts.join(",")
}.call


## Reverse proxy
# We'll now setup a reverse proxy
include_recipe "nginx"
template "shinken/broker/webui/nginx" do
  source    "broker/webui/nginx.cfg.erb"
  path      ::File.join(node["nginx"]["dir"], "sites-available", "shinken-webui")
  variables({
    :server_names => node["fqdn"],
    :port          => 7767
  })

  notifies  :reload, "service[nginx]", :delayed
end

nginx_site "shinken-webui" do
  notifies  :reload, "service[nginx]", :delayed
end


