=begin
  it "raises a custom exception when connection refused" do
    lambda { PrivatePub.publish({}) }.should raise_error(PrivatePub::ConnectionRefused)
  end
  +    rescue Errno::ECONNREFUSED => e
  +      raise PrivatePub::ConnectionRefused, e
       end

       def faye_extension
  @@ -43,4 +45,7 @@ module PrivatePub
     end

     reset_config
  +
  +  class ConnectionRefused < Exception
  +  end
   end
  diff --git a/spec/private_pub_spec.rb b/spec/private_pub_spec.rb
  index c352d3b..41ac608 100644
  --- a/spec/private_pub_spec.rb
  +++ b/spec/private_pub_spec.rb
  @@ -53,6 +53,10 @@ describe PrivatePub do
       Net::HTTP.should_receive(:post_form).with(URI.parse(PrivatePub.config[:server]), "hello world").and_return(:result)
       PrivatePub.publish("hello world").should == :result
     end
  +  
  +  it "raises a custom exception when connection refused" do
  +    lambda { PrivatePub.publish({}) }.should raise_error(PrivatePub::ConnectionRefused)
  +  end

     it "has a FayeExtension instance" do
  
=end

require 'spec_helper'
require 'support/view_helpers_helper.rb'

describe PrivatePub::ViewHelpers do
  describe "publish_to" do
    it "converts any object to a valid channel" do
      resource = Object.new
      expected = '/'+dom_id(resource)
      PrivatePub.should_receive(:publish) do |options|
        JSON.parse(options[:message]).fetch('channel').should == expected
      end
      publish_to(resource) {}
    end

    it "doesn't convert a string" do
      PrivatePub.should_receive(:publish) do |options|
        JSON.parse(options[:message]).fetch('channel').should == '/string'
      end
      publish_to('/string')
    end
    
    it "raises an error unless channel begins with a slash" do
      PrivatePub.should_receive(:publish).once
      lambda { publish_to('invalid') }.should raise_error(PrivatePub::InvalidChannelSyntax, /must begin with a slash/)
      lambda { publish_to('/valid') }.should_not raise_error(PrivatePub::InvalidChannelSyntax)
    end
    
    it "raises an error when channel is nil" do
      lambda { publish_to(nil) }.should raise_error(PrivatePub::InvalidChannelSyntax, "cannot be nil")
    end
    
    it "fail silently when connection refused" do
      lambda { publish_to('/') }.should_not raise_error
    end
  end

  describe "subscribe_to" do
  end
end
