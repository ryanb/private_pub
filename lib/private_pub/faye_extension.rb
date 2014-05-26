module PrivatePub
  # This class is an extension for the Faye::RackAdapter.
  # It is used inside of PrivatePub.faye_app.
  class FayeExtension
    # Callback to handle incoming Faye messages. This authenticates both
    # subscribe and publish calls.
    def incoming(message, callback)
      if is_subscription? message
        check_signature(message)
      elsif is_not_meta? message
        authenticate_publish(message)
      end

      callback.call(message)
    end

  private

    def is_subscription?(message)
       message["channel"] == "/meta/subscribe"
    end

    def is_not_meta?(message)
      message["channel"] !~ %r{^/meta/}
    end

    def channel_of(message)
      message[is_subscription?(message) ? "subscription" : "channel"]
    end

    # Ensure a signature is correct and that it has not expired.
    def check_signature(message)
      subscription = PrivatePub.subscription(:publish => true, :channel => channel_of(message), :timestamp => message["ext"]["private_pub_timestamp"])
      expected_signature = is_subscription?(message) ? subscription[:sub_signature] : subscription[:pub_signature]

      if message["ext"]["private_pub_signature"] != expected_signature
        message["error"] = "Incorrect signature."
      elsif PrivatePub.signature_expired? message["ext"]["private_pub_timestamp"].to_i
        message["error"] = "Signature has expired."
      end
    end

    # Ensures either the correct secret token or publish signature is set
    def authenticate_publish(message)
      if PrivatePub.config[:secret_token].nil?
        raise Error, "No secret_token config set, ensure private_pub.yml is loaded properly."
      end

      if message["ext"]["private_pub_token"]
        if message["ext"]["private_pub_token"] != PrivatePub.config[:secret_token]
          message["error"] = "Incorrect token."
        else
          message["ext"]["private_pub_token"] = nil
        end
      else
        check_signature message
      end
    end
  end
end
