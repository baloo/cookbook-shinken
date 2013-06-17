name "shinken_poller"
description "Monitoring polling server"
run_list "role[monitoring]", "recipe[shinken::poller]", "recipe[shinken::plugins]"

override_attributes( "shinken" => {
                       "poller" => {
                         "modules" => ["NrpeBooster"]
                       }
                     }
)
