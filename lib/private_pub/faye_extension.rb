class PrivatePub
  class FayeExtension
    def incoming(message, callback)
      if message["channel"] == "/meta/subscribe"
        authenticate_subscribe(message)
      elsif message["channel"] !~ %r{^/meta/}
        authenticate_publish(message)
      end
      callback.call(message)
    end

    private

    def authenticate_subscribe(message)
      subscription = PrivatePub.subscription(:channel => message["subscription"], :timestamp => message["ext"]["private_pub_timestamp"])
      if message["ext"]["private_pub_signature"] != subscription[:signature]
        message["error"] = "Incorrect signature."
      elsif PrivatePub.signature_expired? message["ext"]["private_pub_timestamp"].to_i
        message["error"] = "Signature has expired."
      end
    end

    def authenticate_publish(message)
      if PrivatePub.secret_token.nil?
        raise Error, "No token set in PrivatePub.secret_token, set this to match the token used in the web app."
      elsif message["ext"]["private_pub_token"] != PrivatePub.secret_token
        message["error"] = "Incorrect token."
      end
    end
  end
end
