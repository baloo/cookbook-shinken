actions :create, :delete

attribute :contactgroup_key,                   :kind_of => String, :name_attribute => true
attribute :contactgroup_alias,                 :kind_of => String
attribute :contactgroup_name,                  :kind_of => String
attribute :contactgroup_members,               :kind_of => Array
attribute :members,                            :kind_of => Array


attribute :register,                      :kind_of => [TrueClass, FalseClass], :default => true
attribute :use,                           :kind_of => Array


def initialize(*opts)
  super *opts
  @action = :create

  @run_context.include_recipe "shinken::arbiter-contactgroups"
end

