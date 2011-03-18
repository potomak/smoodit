require 'faraday'

# @private
module Faraday
  # @private
  class Response::RaiseHttp5xx < Response::Middleware
    def self.register_on_complete(env)
      env[:response].on_complete do |response|
        case response[:status].to_i
        when 500
          raise Smoodit::InternalServerError, error_message(response, "Something is technically wrong.")
        when 502
          raise Smoodit::BadGateway, error_message(response, "Smood it is down or being upgraded.")
        when 503
          raise Smoodit::ServiceUnavailable, error_message(response, "(__-){ Smood it is over capacity.")
        end
      end
    end

    def initialize(app)
      super
      @parser = nil
    end

    private

    def self.error_message(response, body=nil)
      "#{response[:method].to_s.upcase} #{response[:url].to_s}: #{[response[:status].to_s + ':', body].compact.join(' ')} Check http://status.smood.it/ for updates on the status of the Smood it service."
    end
  end
end
