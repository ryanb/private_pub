module PrivatePub
  # This class is an extension for the Faye::RackAdapter.
  # It is used inside of PrivatePub.faye_app.
  class FayeExtension
    # Callback to handle incoming Faye messages. This authenticates both
    # subscribe and publish calls.
    def incoming(message, callback)
      puts "message to #{message["channel"]}: #{message["data"]}" # TODO: Remove!
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

    # Ensure a signature is correct and that it has not expired.
    def check_signature(message)
      subscription = PrivatePub.subscription(:publish => true, :channel => message["subscription"], :timestamp => message["ext"]["private_pub_timestamp"])
      expected_signature = is_subscription?(message) ? subscription[:sub_signature] : subscription[:pub_signature]

      if message["ext"]["private_pub_signature"] != expected_signature
        message["error"] = "Incorrect signature."
        puts "lol1"
      elsif PrivatePub.signature_expired? message["ext"]["private_pub_timestamp"].to_i
        message["error"] = "Signature has expired."
        puts "lol2"
      end
    end

    # Ensures the secret token is correct before publishing.
    # TODO: change format to allow js clients to publish
    def authenticate_publish(message)
      if PrivatePub.config[:secret_token].nil?
        raise Error, "No secret_token config set, ensure private_pub.yml is loaded properly."
      end

      if message["ext"]["private_pub_token"]
        if message["ext"]["private_pub_token"] != PrivatePub.config[:secret_token]
          message["error"] = "Incorrect token."
          puts "lol3"
        else
          message["ext"]["private_pub_token"] = nil
        end
      else
        check_signature message
      end
    end
  end
end
