# frozen_string_literal: true

require "parallel"

module Dsmr2mqtt
  class Server
    def initialize(configuration)
      @configuration = configuration
    end

    def run!
      Parallel.each(readers, &:run!)
    end

    private

    attr_reader :configuration

    def readers
      [
        Reader.new(
          serial: serial,
          publisher: publisher,
          heartbeat_interval: configuration.fetch("heartbeat_interval", 30)
        )
      ]
    end

    def serial
      config = configuration.fetch("serial")

      Serial.new(port: config.fetch("port"), baud: config.fetch("baud", 115_200))
    end

    def publisher
      Publisher.new(**mqtt_config)
    end

    def mqtt_config
      configuration.fetch("mqtt").then do |config|
        {
          host: config.fetch("host"),
          port: config.fetch("port", 1883),
          username: config.fetch("username", nil),
          password: config.fetch("password", nil),
          topic_prefix: config.fetch("topic_prefix")
        }
      end
    end
  end
end
