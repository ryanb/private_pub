require "spec_helper"

describe PrivatePub do
  before(:each) do
    PrivatePub.reset_config
  end

  it "defaults server to localhost:9292/faye" do
    PrivatePub.config[:server].should == "http://localhost:9292/faye"
  end

  it "defaults signature_expiration to 1 hour" do
    PrivatePub.config[:signature_expiration].should == 60 * 60
  end

  it "defaults subscription timestamp to current time in milliseconds" do
    time = Time.now
    Time.stub!(:now).and_return(time)
    PrivatePub.subscription[:timestamp].should == (time.to_f * 1000).round
  end

  it "loads a simple configuration file via load_config" do
    PrivatePub.load_config("spec/fixtures/private_pub.yml", "production")
    PrivatePub.config[:server].should == "http://example.com/faye"
    PrivatePub.config[:secret_token].should == "PRODUCTION_SECRET_TOKEN"
    PrivatePub.config[:signature_expiration].should == 600
  end

  it "supports a nil signature_expiration via a blank value in the configuration file" do
    PrivatePub.load_config("spec/fixtures/private_pub.yml", :no_signature_expiration)
    PrivatePub.config[:signature_expiration].should be_nil
  end

  it "raises an exception if an invalid environment is passed to load_config" do
    lambda {
      PrivatePub.load_config("spec/fixtures/private_pub.yml", :test)
    }.should raise_error ArgumentError
  end

  it "includes channel and custom time in subscription" do
    subscription = PrivatePub.subscription(:timestamp => 123, :channel => "hello")
    subscription[:timestamp].should == 123
    subscription[:channel].should == "hello"
  end

  it "does a sha1 digest of channel, timestamp, and secret token" do
    PrivatePub.config[:secret_token] = "token"
    subscription = PrivatePub.subscription(:timestamp => 123, :channel => "channel")
    subscription[:signature].should == Digest::SHA1.hexdigest("tokenchannel123")
  end

  it "publishes to server using Net::HTTP" do
    Net::HTTP.should_receive(:post_form).with(URI.parse(PrivatePub.config[:server]), "hello world").and_return(:result)
    PrivatePub.publish("hello world").should == :result
  end

  it "has a FayeExtension instance" do
    PrivatePub.faye_extension.should be_kind_of(PrivatePub::FayeExtension)
  end

  it "says signature has expired when time passed in is greater than expiration" do
    PrivatePub.config[:signature_expiration] = 30*60
    time = PrivatePub.subscription[:timestamp] - 31*60*1000
    PrivatePub.signature_expired?(time).should be_true
  end

  it "says signature has not expired when time passed in is less than expiration" do
    PrivatePub.config[:signature_expiration] = 30*60
    time = PrivatePub.subscription[:timestamp] - 29*60*1000
    PrivatePub.signature_expired?(time).should be_false
  end

  it "says signature has not expired when expiration is nil" do
    PrivatePub.config[:signature_expiration] = nil
    PrivatePub.signature_expired?(0).should be_false
  end
end
