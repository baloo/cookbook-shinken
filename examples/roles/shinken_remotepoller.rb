name "shinken_remotepoller"
description "Remote monitoring polling server"
run_list "role[shinken_poller]"

override_attributes( "shinken" => {
                       "poller" => {
                         "ipaddress" => "2.3.4.5",
                         "variables" => {
                           "poller_tags" => "othersite.com"
                         }
                       }
                     }
)
