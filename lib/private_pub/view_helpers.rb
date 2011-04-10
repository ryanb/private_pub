module PrivatePub
  module ViewHelpers
    def parse_channel(channel)
      raise(PrivatePub::InvalidChannelSyntax, "cannot be nil") if channel.nil?
      channel = '/'+dom_id(channel) unless channel.is_a?(String)
      raise(PrivatePub::InvalidChannelSyntax, "must begin with a slash") unless channel[0] == '/'
      channel
    end

    def publish_to(channel, object = nil, &block)
      channel = parse_channel(channel)
      message = {:channel => channel, :data => {:channel => channel}, :ext => {:private_pub_token => PrivatePub.config[:secret_token]}}
      message[:data][:eval] = capture(&block) if block_given?
      message[:data][:data] = object if object
      PrivatePub.publish(:message => message.to_json)
    end

    def subscribe_to(channel)
      channel = parse_channel(channel)
      subscription = PrivatePub.subscription(:channel => channel)
      subscription[:server] = PrivatePub.config[:server]
      content_tag "script", :type => "text/javascript" do
        raw("PrivatePub.sign(#{subscription.to_json});")
      end
    end
  end
  
  class InvalidChannelSyntax < Exception
  end
end
