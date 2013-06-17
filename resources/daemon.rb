actions :create, :delete

attribute :name, :name_attribute => true, :regex => /^[a-zA-Z0-9_]+$/
attribute :daemon_type, :required => true, :callbacks => {
  "is not a valid type" => Proc.new { |el|
    [:arbiter,
     :broker,
     :poller,
     :reactionner,
     :receiver,
     :scheduler].include?(el)
  }
}

attribute :variables, :kind_of => Hash
attribute :modules, :kind_of => Array

attribute :address, :kind_of => String, :required => true
attribute :port, :kind_of => Integer, :required => true

def initialize(*opts)
  super *opts
  @action = :create

  @run_context.include_recipe "shinken::arbiter"
end
