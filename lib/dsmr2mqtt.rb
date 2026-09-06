# frozen_string_literal: true

require "logger"
require "yaml"

module Dsmr2mqtt
  class << self
    attr_writer :logger

    def logger
      @logger ||= Logger.new($stdout)
    end

    def run!(config_file)
      config = YAML.load_file(config_file)
      logger.debug "Starting server with configuration: #{redact(config).inspect}"
      Server.new(config).run!
    end

    def install!(config_file)
      Install::Systemd.new(config_path: File.expand_path(config_file)).run!
    end

    private

    def redact(config)
      config.merge(
        "mqtt" => config.fetch("mqtt", {}).merge("password" => "<REDACTED>")
      )
    rescue StandardError
      config
    end
  end
end

require_relative "dsmr2mqtt/version"
require_relative "dsmr2mqtt/telegram"
require_relative "dsmr2mqtt/mqtt"
require_relative "dsmr2mqtt/publisher"
require_relative "dsmr2mqtt/serial"
require_relative "dsmr2mqtt/reader"
require_relative "dsmr2mqtt/server"
require_relative "dsmr2mqtt/install/systemd"
