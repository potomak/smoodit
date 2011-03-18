require 'faraday_middleware'
Dir[File.expand_path('../../faraday/*.rb', __FILE__)].each{|f| require f}

module Smoodit
  # @private
  module Connection
    private

    def connection(raw=false)
      options = {
        :headers => {
          'Accept' => "application/#{format}",
          'Content-type' => "application/#{format}",
          'User-Agent' => user_agent
        },
        :proxy => proxy,
        :ssl => {:verify => false},
        :url => api_endpoint,
      }

      Faraday::Connection.new(options) do |builder|
        builder.use Faraday::Request::Multipart
        builder.use Faraday::Request::Yajl if format == :json
        builder.use Faraday::Request::OAuth, authentication if authenticated?
        builder.adapter(adapter)
        builder.use Faraday::Response::RaiseHttp5xx
        unless raw
          case format.to_s.downcase
          when 'json' then builder.use Faraday::Response::ParseJson
          when 'xml' then builder.use Faraday::Response::ParseXml
          end
        end
        builder.use Faraday::Response::RaiseHttp4xx
        builder.use Faraday::Response::Mashify unless raw
      end
    end
  end
end
