actions :create, :delete


attribute :key,                             :kind_of => String, :name_attribute => true
attribute :hostname,                        :kind_of => String
attribute :service_description,             :kind_of => String
attribute :dependent_hostname,              :kind_of => String
attribute :dependent_service_description,   :kind_of => String

attribute :register,                        :kind_of => [TrueClass, FalseClass], :default => true
attribute :use,                             :kind_of => Array


def initialize(*opts)
  super *opts
  @action = :create

  @run_context.include_recipe "shinken::arbiter-service-dependencies"
end
