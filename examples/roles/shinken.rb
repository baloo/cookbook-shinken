name "shinken"
description "Monitoring server"
run_list "role[monitoring]", "recipe[shinken::mongodb]", "recipe[mongodb]", 
"recipe[shinken::pnp]","role[shinken_poller]", "recipe[shinken::reactionner]", 
"recipe[shinken::scheduler]", "recipe[shinken::broker]", "recipe[shinken::thruk]", 
"recipe[shinken::receiver]",  "recipe[shinken::arbiter]", "recipe[shinken::plugins]",
"recipe[shinken::xmpp]"

override_attributes( "shinken" => {
                       "arbiter" => {
                         "modules" => ["CommandFile"]
                       },
                       "broker" => {
                         "modules" => [ "Livestatus", "NPCDMOD", "Simple-log", "WebUI"]
                       },
                       "poller" => {
                         "variables" => {
                           "poller_tags" => "None,example.com"
                         }
                       },
                       "scheduler" => {
                         "ipaddress" => "1.2.3.4",
                         "modules" => ["PickleRetention"]
                       },
                       "xmpp" => {
                         "username" => "myuser@jabber.org",
                         "domain" => "jabber.org",
                         "password" => "123456",
                         "server" => "jabber.org",
                         "port" => "5222"
                       },
                       "cgi" => {
                         "admin_group" => "sysadmin",
                         "read_groups" => "dev,qa"
                       },
                       "auto_poller_tags" => true,
                       "cert_name" => "_.example.com",
                       "cert_ca_name" => "gd_bundle",
                     }
)
