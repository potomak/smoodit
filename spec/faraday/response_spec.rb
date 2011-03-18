require File.expand_path('../../spec_helper', __FILE__)

describe Faraday::Response do
  before do
    @client = Smoodit::Client.new
  end

  {
    400 => Smoodit::BadRequest,
    401 => Smoodit::Unauthorized,
    403 => Smoodit::Forbidden,
    404 => Smoodit::NotFound,
    406 => Smoodit::NotAcceptable,
    500 => Smoodit::InternalServerError,
    502 => Smoodit::BadGateway,
    503 => Smoodit::ServiceUnavailable,
  }.each do |status, exception|
    context "when HTTP status is #{status}" do

      before do
        stub_get('users/171').to_return(:status => status)
      end

      it "should raise #{exception.name} error" do
        lambda do
          @client.users(171) {|user| user}
        end.should raise_error(exception)
      end
    end
  end
end
