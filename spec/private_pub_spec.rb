require "spec_helper"

describe PrivatePub do
  before(:each) do
    PrivatePub.reset_config
  end

  it "defaults server to nil" do
    expect(PrivatePub.config[:server]).to be_nil
  end

  it "defaults signature_expiration to nil" do
    expect(PrivatePub.config[:signature_expiration]).to be_nil
  end

  it "defaults subscription timestamp to current time in milliseconds" do
    time = Time.now
    allow(Time).to receive(:now).and_return(time)
    expect(PrivatePub.subscription[:timestamp]).to eq((time.to_f * 1000).round)
  end

  it "loads a simple configuration file via load_config" do
    PrivatePub.load_config("spec/fixtures/private_pub.yml", "production")
    expect(PrivatePub.config[:server]).to eq("http://example.com/faye")
    expect(PrivatePub.config[:secret_token]).to eq("PRODUCTION_SECRET_TOKEN")
    expect(PrivatePub.config[:signature_expiration]).to eq(600)
  end

  it "raises an exception if an invalid environment is passed to load_config" do
    expect {
      PrivatePub.load_config("spec/fixtures/private_pub.yml", :test)
    }.to raise_error ArgumentError
  end

  it "includes channel, server, and custom time in subscription" do
    PrivatePub.config[:server] = "server"
    subscription = PrivatePub.subscription(:timestamp => 123, :channel => "hello")
    expect(subscription[:timestamp]).to eq(123)
    expect(subscription[:channel]).to eq("hello")
    expect(subscription[:server]).to eq("server")
  end

  it "does a sha1 digest of channel, timestamp, and secret token" do
    PrivatePub.config[:secret_token] = "token"
    subscription = PrivatePub.subscription(:timestamp => 123, :channel => "channel")
    expect(subscription[:signature]).to eq(Digest::SHA1.hexdigest("tokenchannel123"))
  end

  it "formats a message hash given a channel and a string for eval" do
    PrivatePub.config[:secret_token] = "token"
    expect(PrivatePub.message("chan", "foo")).to eq(
      :ext => {:private_pub_token => "token"},
      :channel => "chan",
      :data => {
        :channel => "chan",
        :eval => "foo"
      }
    )
  end

  it "formats a message hash given a channel and a hash" do
    PrivatePub.config[:secret_token] = "token"
    expect(PrivatePub.message("chan", :foo => "bar")).to eq(
      :ext => {:private_pub_token => "token"},
      :channel => "chan",
      :data => {
        :channel => "chan",
        :data => {:foo => "bar"}
      }
    )
  end

  it "publish message as json to server using Net::HTTP" do
    PrivatePub.config[:server] = "http://localhost"
    message = 'foo'
    form = double(:post).as_null_object
    http = double(:http).as_null_object

    expect(Net::HTTP::Post).to receive(:new).with('/').and_return(form)
    expect(form).to receive(:set_form_data).with(message: 'foo'.to_json)

    expect(Net::HTTP).to receive(:new).with('localhost', 80).and_return(http)
    expect(http).to receive(:start).and_yield(http)
    expect(http).to receive(:request).with(form).and_return(:result)

    expect(PrivatePub.publish_message(message)).to eq(:result)
  end

  it "it should use HTTPS if the server URL says so" do
    PrivatePub.config[:server] = "https://localhost"
    http = double(:http).as_null_object

    expect(Net::HTTP).to receive(:new).and_return(http)
    expect(http).to receive(:use_ssl=).with(true)

    PrivatePub.publish_message('foo')
  end

  it "it should not use HTTPS if the server URL says not to" do
    PrivatePub.config[:server] = "http://localhost"
    http = double(:http).as_null_object

    expect(Net::HTTP).to receive(:new).and_return(http)
    expect(http).to receive(:use_ssl=).with(false)

    PrivatePub.publish_message('foo')
  end

  it "raises an exception if no server is specified when calling publish_message" do
    expect {
      PrivatePub.publish_message("foo")
    }.to raise_error(PrivatePub::Error)
  end

  it "publish_to passes message to publish_message call" do
    expect(PrivatePub).to receive(:message).with("chan", "foo").and_return("message")
    expect(PrivatePub).to receive(:publish_message).with("message").and_return(:result)
    expect(PrivatePub.publish_to("chan", "foo")).to eq(:result)
  end

  it "has a Faye rack app instance" do
    expect(PrivatePub.faye_app).to be_kind_of(Faye::RackAdapter)
  end

  it "says signature has expired when time passed in is greater than expiration" do
    PrivatePub.config[:signature_expiration] = 30*60
    time = PrivatePub.subscription[:timestamp] - 31*60*1000
    expect(PrivatePub.signature_expired?(time)).to be_truthy
  end

  it "says signature has not expired when time passed in is less than expiration" do
    PrivatePub.config[:signature_expiration] = 30*60
    time = PrivatePub.subscription[:timestamp] - 29*60*1000
    expect(PrivatePub.signature_expired?(time)).to be_falsey
  end

  it "says signature has not expired when expiration is nil" do
    PrivatePub.config[:signature_expiration] = nil
    expect(PrivatePub.signature_expired?(0)).to be_falsey
  end
end
