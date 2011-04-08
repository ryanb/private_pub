module PrivatePub
  module ViewHelpers
    def publish_to(channel, object = nil, &block)
      message = {:channel => channel, :data => {:channel => channel}, :ext => {:private_pub_token => PrivatePub.config[:secret_token]}}
      message[:data][:_data] = block_given? ? capture(&block) : object.to_json
      PrivatePub.publish(:message => message.to_json)
    end

    def subscribe_to(channel)
      subscription = PrivatePub.subscription(:channel => channel)
      content_tag :span, "", :class => "private_pub_subscription",
        "data-server" => PrivatePub.config[:server],
        "data-channel" => subscription[:channel],
        "data-signature" => subscription[:signature],
        "data-timestamp" => subscription[:timestamp]
    end
  end
end
