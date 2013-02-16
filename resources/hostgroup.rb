actions :create, :delete


attribute :hostgroup_key,   :kind_of => String, :name_attribute => true
attribute :hostgroup_name,  :kind_of => String
attribute :hostgroup_alias, :kind_of => String
attribute :notes,           :kind_of => String
attribute :notes_url,       :kind_of => String
attribute :action_url,      :kind_of => String
attribute :realm,           :kind_of => String

attribute :register,        :kind_of => [TrueClass, FalseClass], :default => true
attribute :use,             :kind_of => Array


def initialize(*opts)
  super *opts
  @action = :create

  @run_context.include_recipe "shinken::arbiter-hostgroups"
end
