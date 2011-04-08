module PrivatePub
  module ViewHelpers
    def publish_to(channel, object = nil, &block)
      message = {:channel => channel, :data => {}, :ext => {:private_pub_token => PrivatePub.config[:secret_token]}}
      message[:data][:_data] = block_given? ? capture(&block) : object.to_json
      PrivatePub.publish(:message => message.to_json)
    end

    def subscribe_to(channel, options = {})
      subscription = PrivatePub.subscription(:channel => channel)
      span_options = {
        :class => "private_pub_subscription",
        "data-server" => PrivatePub.config[:server],
        "data-channel" => subscription[:channel],
        "data-signature" => subscription[:signature],
        "data-timestamp" => subscription[:timestamp]
      }
      span_options["data-callback"] = options[:callback] if options[:callback]
      content_tag :span, "", span_options
    end
  end
end
