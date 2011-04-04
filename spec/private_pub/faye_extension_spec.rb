require "spec_helper"

describe PrivatePub::FayeExtension do
  before(:each) do
    PrivatePub.reset_config
    @faye = PrivatePub::FayeExtension.new
    @message = {"channel" => "/meta/subscribe", "ext" => {}}
  end

  it "adds an error on an incoming subscription with a bad key" do
    @message["subscription"] = "hello"
    @message["ext"]["private_pub_key"] = "bad"
    @message["ext"]["private_pub_timestamp"] = "123"
    message = @faye.incoming(@message, lambda { |m| m })
    message["error"].should == "Incorrect key."
  end

  it "has no error when the key matches the subscription" do
    sub = PrivatePub.subscription(:timestamp => 123, :channel => "hello")
    @message["subscription"] = sub[:channel]
    @message["ext"]["private_pub_key"] = sub[:key]
    @message["ext"]["private_pub_timestamp"] = sub[:timestamp]
    message = @faye.incoming(@message, lambda { |m| m })
    message["error"].should be_nil
  end

  it "has an error when trying to publish to a custom channel with a bad token" do
    PrivatePub.secret_token = "good"
    @message["channel"] = "/custom/channel"
    @message["ext"]["private_pub_token"] = "bad"
    message = @faye.incoming(@message, lambda { |m| m })
    message["error"].should == "Incorrect token."
  end

  it "raises an exception when attempting to call a custom channel without a secret_token set" do
    @message["channel"] = "/custom/channel"
    @message["ext"]["private_pub_token"] = "bad"
    lambda {
      message = @faye.incoming(@message, lambda { |m| m })
    }.should raise_error("No token set in PrivatePub.secret_token, set this to match the token used in the web app.")
  end

  it "has no error on other meta calls" do
    @message["channel"] = "/meta/connect"
    message = @faye.incoming(@message, lambda { |m| m })
    message["error"].should be_nil
  end
end
