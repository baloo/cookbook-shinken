actions :create, :delete


attribute :timeperiod_key,   :kind_of => String, :name_attribute => true
attribute :timeperiod_alias, :kind_of => String
attribute :timeperiod_name,  :kind_of => String
attribute :exclude,          :kind_of => Array
attribute :content,          :kind_of => Array

attribute :register,         :kind_of => [TrueClass, FalseClass], :default => true
attribute :use,              :kind_of => Array


def initialize(*opts)
  super *opts
  @action = :create

  @run_context.include_recipe "shinken::arbiter-timeperiods"
end
