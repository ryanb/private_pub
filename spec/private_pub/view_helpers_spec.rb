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
  end

  describe "subscribe_to" do
  end
end
