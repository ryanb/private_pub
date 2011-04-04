require "digest/sha1"
require "net/http"

class PrivatePub
  class << self
    def server=(server)
      @config[:server] = server
    end

    def server
      @config[:server]
    end

    def key_expiration=(key_expiration)
      @config[:key_expiration] = key_expiration
    end

    def key_expiration
      @config[:key_expiration]
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
        :key_expiration => 60 * 60, # one hour
      }
    end

    def subscription(options = {})
      sub = {:timestamp => (Time.now.to_f * 1000).round}.merge(options)
      sub[:key] = Digest::SHA1.hexdigest([secret_token, sub[:channel], sub[:timestamp]].join)
      sub
    end

    def publish(data)
      Net::HTTP.post_form(URI.parse(PrivatePub.server), data)
    end
  end
  reset_config
end
