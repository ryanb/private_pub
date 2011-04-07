require "digest/sha1"
require "net/http"

require "private_pub/faye_extension"
require "private_pub/utils"

class PrivatePub
  class Error < StandardError; end

  class << self
    attr_reader :config

    def reset_config
      @config = {
        :server => "http://localhost:9292/faye",
        :signature_expiration => 60 * 60, # one hour
      }
    end

    def load_config(filename, environment)
      config = PrivatePub::Utils.symbolize_keys YAML.load_file(filename)
      parse_config(config, environment.to_sym)
    end

    def parse_config(data, environment)
      raise ArgumentError.new("invalid environment: #{environment.to_s}") if data[environment].nil?
      @config.merge!(data[environment])
    end

    def subscription(options = {})
      sub = {:timestamp => (Time.now.to_f * 1000).round}.merge(options)
      sub[:signature] = Digest::SHA1.hexdigest([config[:secret_token], sub[:channel], sub[:timestamp]].join)
      sub
    end

    def publish(data)
      Net::HTTP.post_form(URI.parse(config[:server]), data)
    end

    def faye_extension
      FayeExtension.new
    end

    def signature_expired?(timestamp)
      timestamp < ((Time.now.to_f - config[:signature_expiration])*1000).round if config[:signature_expiration]
    end
  end

  reset_config
end
