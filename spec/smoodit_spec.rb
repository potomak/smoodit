require File.expand_path('../spec_helper', __FILE__)

describe Smoodit do
  after do
    Smoodit.reset
  end

  context "when delegating to a client" do
    before do
      stub_get("john").
        to_return(:body => fixture("user_john.js"), :headers => {:content_type => "application/json; charset=utf-8"})
    end

    it "should get the correct resource" do
      Smoodit.john {|user| user}
      a_get("john").
        should have_been_made
    end

    it "should return the same results as a client" do
      class_obj = nil
      client_obj = nil
    
      Smoodit.john {|user| class_obj = user}
      Smoodit::Client.new.john {|user| client_obj = user}
    
      class_obj.should == client_obj
    end
  end
  
  context "when making a request to" do
    # https://github.com/smoodit/api/wiki/User-profile
    # https://github.com/smoodit/api/wiki/Your-profile
    ["john", "profile"].each do |member|
      describe "GET #{member}" do
        before do
          stub_get(member)
          
          @request = Smoodit.send(member) {|r| r}
        end

        it "should use '#{member}' request path" do
          @request.proxy.path.should == member
        end
        
        it "should use GET request verb" do
          @request.proxy.verb.should == :get
        end
      end
    end
    
    # https://github.com/smoodit/api/wiki/Followers
    # https://github.com/smoodit/api/wiki/Following
    # https://github.com/smoodit/api/wiki/User-smoods
    ["followers", "following", "smoods"].each do |member|
      describe "GET john/#{member}" do
        before do
          stub_get("john/#{member}")
          
          @request = Smoodit.john.send(member) {|r| r}
        end

        it "should use 'john/#{member}' request path" do
          @request.proxy.path.should == "john/#{member}"
        end
        
        it "should use GET request verb" do
          @request.proxy.verb.should == :get
        end
      end
    end
    
    # https://github.com/smoodit/api/wiki/Your-smoods
    describe "GET profile/smoods" do
      before do
        stub_get("profile/smoods")
        
        @request = Smoodit.profile.smoods {|r| r}
      end

      it "should use 'profile/smoods' request path" do
        @request.proxy.path.should == "profile/smoods"
      end
      
      it "should use GET request verb" do
        @request.proxy.verb.should == :get
      end
    end
    
    # https://github.com/smoodit/api/wiki/Follow-user
    # https://github.com/smoodit/api/wiki/Unfollow-user
    ["follow", "unfollow"].each do |member|
      describe "POST users/123/#{member}" do
        before do
          stub_post("users/123/#{member}")
      
          @request = Smoodit.users(123).send(member).post {|r| r}
        end
    
        it "should use 'users/123/#{member}' request path" do
          @request.proxy.path.should == "users/123/#{member}"
        end
    
        it "should use POST request verb" do
          @request.proxy.verb.should == :post
        end
      end
    end
    
    # https://github.com/smoodit/api/wiki/Create-new-smood
    describe "POST smoods" do
      before do
        stub_post("smoods")
        
        Smoodit.configure do |config|
          config.format = :test
        end
      
        @options = {
          :smood => {
            :mood => :anger
          }
        }
        
        @request = Smoodit.smoods.post(@options) {|r| r}
      end
    
      it "should use 'smoods' request path" do
        @request.proxy.path.should == "smoods"
      end
    
      it "should use POST request verb" do
        @request.proxy.verb.should == :post
      end
    
      it "should include new smood parameters into request" do
        @request.proxy.options.should == @options
      end
    end
    
    # https://github.com/smoodit/api/wiki/Delete-smood
    describe "DELETE smoods/123" do
      before do
        stub_delete("smoods/123")
      
        @request = Smoodit.smoods(123).delete {|r| r}
      end
    
      it "should use 'smoods/123' request path" do
        @request.proxy.path.should == "smoods/123"
      end
    
      it "should use DELETE request verb" do
        @request.proxy.verb.should == :delete
      end
    end
  end

  describe ".client" do
    it "should be a Smoodit::Client" do
      Smoodit.client.should be_a Smoodit::Client
    end
  end

  describe ".adapter" do
    it "should return the default adapter" do
      Smoodit.adapter.should == Smoodit::Configuration::DEFAULT_ADAPTER
    end
  end

  describe ".adapter=" do
    it "should set the adapter" do
      Smoodit.adapter = :typhoeus
      Smoodit.adapter.should == :typhoeus
    end
  end

  describe ".endpoint" do
    it "should return the default endpoint" do
      Smoodit.endpoint.should == Smoodit::Configuration::DEFAULT_ENDPOINT
    end
  end

  describe ".endpoint=" do
    it "should set the endpoint" do
      Smoodit.endpoint = 'http://tumblr.com/'
      Smoodit.endpoint.should == 'http://tumblr.com/'
    end
  end

  describe ".format" do
    it "should return the default format" do
      Smoodit.format.should == Smoodit::Configuration::DEFAULT_FORMAT
    end
  end

  describe ".format=" do
    it "should set the format" do
      Smoodit.format = 'xml'
      Smoodit.format.should == 'xml'
    end
  end

  describe ".user_agent" do
    it "should return the default user agent" do
      Smoodit.user_agent.should == Smoodit::Configuration::DEFAULT_USER_AGENT
    end
  end

  describe ".user_agent=" do
    it "should set the user_agent" do
      Smoodit.user_agent = 'Custom User Agent'
      Smoodit.user_agent.should == 'Custom User Agent'
    end
  end

  describe ".configure" do
    Smoodit::Configuration::VALID_OPTIONS_KEYS.each do |key|

      it "should set the #{key}" do
        Smoodit.configure do |config|
          config.send("#{key}=", key)
          Smoodit.send(key).should == key
        end
      end
    end
  end
end
