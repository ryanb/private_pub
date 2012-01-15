require "digest/sha1"
require "net/http"

require "private_pub/faye_extension"
require "private_pub/engine" if defined? Rails

module PrivatePub
  class Error < StandardError; end

  class << self
    attr_reader :config

    def reset_config
      @config = {}
    end

    def load_config(filename, environment)
      yaml = YAML.load_file(filename)[environment.to_s]
      raise ArgumentError, "The #{environment} environment does not exist in #{filename}" if yaml.nil?
      yaml.each { |k, v| config[k.to_sym] = v }
    end

    def subscription(options = {})
      sub = {:server => config[:server], :timestamp => (Time.now.to_f * 1000).round}.merge(options)
      sub[:signature] = Digest::SHA1.hexdigest([config[:secret_token], sub[:channel], sub[:timestamp]].join)
      sub
    end

    def publish_to(channel, data)
      publish_message(message(channel, data))
    end

    def message(channel, data)
      message = {:channel => channel, :data => {:channel => channel}, :ext => {:private_pub_token => config[:secret_token]}}
      if data.kind_of? String
        message[:data][:eval] = data
      else
        message[:data][:data] = data
      end
      message
    end

    def publish_message(message)
      Net::HTTP.post_form(URI.parse(config[:server]), :message => message.to_json)
    end

    def signature_expired?(timestamp)
      timestamp < ((Time.now.to_f - config[:signature_expiration])*1000).round if config[:signature_expiration]
    end

    def faye_app(options = {})
      options = {:mount => "/faye", :timeout => 45, :extensions => [FayeExtension.new]}.merge(options)
      Faye::RackAdapter.new(options)
    end
  end

  reset_config
end
