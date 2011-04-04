require "spec_helper"

describe PrivatePub do
  before(:each) do
    PrivatePub.reset_config
  end

  it "has secret token, server, and key expiration settings" do
    PrivatePub.secret_token = "secret token"
    PrivatePub.secret_token.should == "secret token"
    PrivatePub.server = "http://localhost/"
    PrivatePub.server.should == "http://localhost/"
    PrivatePub.key_expiration = 1000
    PrivatePub.key_expiration.should == 1000
  end

  it "defaults server to localhost:9292/faye" do
    PrivatePub.server.should == "http://localhost:9292/faye"
  end

  it "defaults key_expiration to 1 hour" do
    PrivatePub.key_expiration.should == 60 * 60
  end

  it "defaults subscription timestamp to current time in milliseconds" do
    time = Time.now
    Time.stub!(:now).and_return(time)
    PrivatePub.subscription[:timestamp].should == (time.to_f * 1000).round
  end

  it "includes channel and custom time in subscription" do
    subscription = PrivatePub.subscription(:timestamp => 123, :channel => "hello")
    subscription[:timestamp].should == 123
    subscription[:channel].should == "hello"
  end

  it "does a sha1 digest of channel, timestamp, and secret token" do
    PrivatePub.secret_token = "token"
    subscription = PrivatePub.subscription(:timestamp => 123, :channel => "channel")
    subscription[:key].should == Digest::SHA1.hexdigest("tokenchannel123")
  end

  it "publishes to server using Net::HTTP" do
    Net::HTTP.should_receive(:post_form).with(URI.parse(PrivatePub.server), "hello world").and_return(:result)
    PrivatePub.publish("hello world").should == :result
  end

  it "has a FayeExtension instance" do
    PrivatePub.faye_extension.should be_kind_of(PrivatePub::FayeExtension)
  end
end
