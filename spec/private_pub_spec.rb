require "spec_helper"

describe PrivatePub do
  before(:each) do
    PrivatePub.reset_config
  end

  it "has secret token, server, and signature expiration settings" do
    PrivatePub.secret_token = "secret token"
    PrivatePub.secret_token.should == "secret token"
    PrivatePub.server = "http://localhost/"
    PrivatePub.server.should == "http://localhost/"
    PrivatePub.signature_expiration = 1000
    PrivatePub.signature_expiration.should == 1000
  end

  it "defaults server to localhost:9292/faye" do
    PrivatePub.server.should == "http://localhost:9292/faye"
  end

  it "defaults signature_expiration to 1 hour" do
    PrivatePub.signature_expiration.should == 60 * 60
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
    subscription[:signature].should == Digest::SHA1.hexdigest("tokenchannel123")
  end

  it "publishes to server using Net::HTTP" do
    Net::HTTP.should_receive(:post_form).with(URI.parse(PrivatePub.server), "hello world").and_return(:result)
    PrivatePub.publish("hello world").should == :result
  end

  it "has a FayeExtension instance" do
    PrivatePub.faye_extension.should be_kind_of(PrivatePub::FayeExtension)
  end

  it "says signature has expired when time passed in is greater than expiration" do
    PrivatePub.signature_expiration = 30*60
    time = PrivatePub.subscription[:timestamp] - 31*60*1000
    PrivatePub.signature_expired?(time).should be_true
  end

  it "says signature has not expired when time passed in is less than expiration" do
    PrivatePub.signature_expiration = 30*60
    time = PrivatePub.subscription[:timestamp] - 29*60*1000
    PrivatePub.signature_expired?(time).should be_false
  end

  it "says signature has not expired when expiration is nil" do
    PrivatePub.signature_expiration = nil
    PrivatePub.signature_expired?(0).should be_false
  end
end
