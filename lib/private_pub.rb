require "digest/sha1"
require "net/http"

require "private_pub/faye_extension"

class PrivatePub
  class Error < StandardError; end

  class << self
    def server=(server)
      @config[:server] = server
    end

    def server
      @config[:server]
    end

    def signature_expiration=(signature_expiration)
      @config[:signature_expiration] = signature_expiration
    end

    def signature_expiration
      @config[:signature_expiration]
    end

    def secret_token=(secret_token)
      @config[:secret_token] = secret_token
    end

    def secret_token
      @config[:secret_token]
    end

    def reset_config
      @config = {
        :server => "http://localhost:9292/faye",
        :signature_expiration => 60 * 60, # one hour
      }
    end

    def subscription(options = {})
      sub = {:timestamp => (Time.now.to_f * 1000).round}.merge(options)
      sub[:signature] = Digest::SHA1.hexdigest([secret_token, sub[:channel], sub[:timestamp]].join)
      sub
    end

    def publish(data)
      Net::HTTP.post_form(URI.parse(PrivatePub.server), data)
    end

    def faye_extension
      FayeExtension.new
    end

    def signature_expired?(timestamp)
      timestamp < ((Time.now.to_f - PrivatePub.signature_expiration)*1000).round if PrivatePub.signature_expiration
    end
  end

  reset_config
end
