actions :create, :delete


attribute :servicegroup_key,   :kind_of => String, :name_attribute => true
attribute :servicegroup_name,  :kind_of => String
attribute :servicegroup_alias, :kind_of => String
attribute :notes,              :kind_of => String
attribute :notes_url,          :kind_of => String

attribute :register,           :kind_of => [TrueClass, FalseClass], :default => true
attribute :use,                :kind_of => Array


def initialize(*opts)
  super *opts
  @action = :create

  @run_context.include_recipe "shinken::arbiter-servicegroups"
end
