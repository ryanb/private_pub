module PrivatePub
  module ViewHelpers
    def publish_to(channel, object = nil, &block)
      message = {:channel => channel, :data => {:channel => channel}, :ext => {:private_pub_token => PrivatePub.config[:secret_token]}}
      message[:data][:eval] = capture(&block) if block_given?
      message[:data][:data] = object if object
      PrivatePub.publish(:message => message.to_json)
    end

    def subscribe_to(channel)
      subscription = PrivatePub.subscription(:channel => channel)
      subscription[:server] = PrivatePub.config[:server]
      content_tag "script", :type => "text/javascript" do
        raw("PrivatePub.sign(#{subscription.to_json});")
      end
    end
  end
end
