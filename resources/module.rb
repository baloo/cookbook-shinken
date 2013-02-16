actions :create, :delete

attribute :name, :name_attribute => true, :regex => /^[a-zA-Z0-9_]+$/
attribute :module_type, :kind_of => Symbol

attribute :variables, :kind_of => Hash

attribute :modules, :kind_of => Array


def initialize(*opts)
  super *opts
  @action = :create

  @run_context.include_recipe "shinken::arbiter"
end
