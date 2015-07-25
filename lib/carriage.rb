require 'benchmark'
require 'securerandom'
require 'yaml'
require 'serverengine'
require 'redis'

require 'carriage/pushable'
require 'carriage/server'
require 'carriage/worker'
require 'carriage/job'
require 'carriage/perform_async_output'

Redis.autoload :Namespace, 'redis/namespace'

class Carriage
  DEFAULT_CONFIG = {

  }
  FORCE_CONFIG = {
    worker_type: 'process',
    supervisor: true,
  }

  attr_accessor :redis, :config

  def initialize
    env = ENV["RAILS_ENV"] || ENV["RACK_ENV"] || "development"
    @config = begin
      c = YAML.load_file("./config/carriage.yml")

      symbolize = -> (h) {
        return h unless h.respond_to?(:to_h)

        h.to_h.map { |key, value|
          key = key.to_sym rescue key
          [key, symbolize.call(value)]
        }.to_h
      }

      c = symbolize.call(c)
      c[env.to_sym] || {}
    rescue Errno::ENOENT => e
      warn e.message
      {}
    end

    @config.delete(:daemonize)

    if @config[:rails] == true
      require 'carriage/rails'
    end

    redis = Redis.new(@config[:redis] || {})
    @redis = if @config.fetch(:redis, {})[:namespace]
      Redis::Namespace.new(@config[:redis][:namespace], redis: redis)
    else
      redis
    end
  end

  def run(opts = {})
    $stdout.sync = true
    ServerEngine.create(Server, Worker) do
      DEFAULT_CONFIG.merge(@config).merge(opts).merge(FORCE_CONFIG)
    end.run
  end
end
