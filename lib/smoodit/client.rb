module Smoodit
  # Wrapper for the Smoodit REST API
  #
  # @note See the {http://smood.it/api Smoodit API Documentation} for more informations.
  # @see http://smood.it/api
  class Client < API
    # Require client method modules after initializing the Client class in
    # order to avoid a superclass mismatch error, allowing those modules to be
    # Client-namespaced.
    Dir[File.expand_path('../client/*.rb', __FILE__)].each{|f| require f}

    alias :api_endpoint :endpoint
    
    attr_reader :proxy
    
    def initialize(options={})
      super(options)
      @proxy = Proxy.new
    end
    
    # Delegate to Smoodit::Client
    def method_missing(method, *args, &block)
      options = args.last.is_a?(Hash) ? args.pop : {}
      id = args.last ? args.pop : nil
      
      # puts "method: #{method}"
      # puts "options: #{options.inspect}"
      # puts "id: #{id}"
      
      @proxy.append(method, id, options)
      
      if block_given?
        @proxy.compose_request
        raw = @proxy.options.delete(:raw)
        response, status = send(:request, @proxy.verb, @proxy.path, @proxy.options, raw)
        case block.arity
        when 0, -1
          yield
        when 1
          yield response
        when 2
          yield response, status
        end
      end
      
      self
      
      # begin
      #   send(verb, path, options)
      # rescue Yajl::ParseError => e
      #   puts "error: #{e}"
      # end
    end
  end
end
