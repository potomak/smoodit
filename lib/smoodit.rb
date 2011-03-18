require File.expand_path('../smoodit/error', __FILE__)
require File.expand_path('../smoodit/configuration', __FILE__)
require File.expand_path('../smoodit/api', __FILE__)
require File.expand_path('../smoodit/client', __FILE__)

module Smoodit
  extend Configuration

  # Alias for Smoodit::Client.new
  #
  # @return [Smoodit::Client]
  def self.client(options={})
    Smoodit::Client.new(options)
  end

  # Delegate to Smoodit::Client
  def self.method_missing(method, *args, &block)
    #return super unless client.respond_to?(method)
    client.send(method, *args, &block)
  end
end
