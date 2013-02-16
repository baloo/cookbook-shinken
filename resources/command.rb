actions :create, :delete

attribute :command,      :kind_of => String, :required => true
attribute :arguments,    :kind_of => Array, :default => []

attribute :command_name, :kind_of => String

require 'zlib'

def command_identifier
  if not command_name.nil?
    command_name
  else
    hash = Zlib.crc32(([self.command] + self.arguments).to_s)

    "#{self.command}_#{hash}"
  end
end

def initialize(*opts)
  super *opts
  @action = :create

  @run_context.include_recipe "shinken::arbiter-commands"
end
