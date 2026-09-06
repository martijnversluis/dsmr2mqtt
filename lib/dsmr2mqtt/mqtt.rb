# frozen_string_literal: true

require "mqtt"

module Dsmr2mqtt
  class Mqtt
    class << self
      # Returns a connected, persistent client the caller is responsible for
      # disconnecting. Use this for a long-lived publisher.
      def client(host:, port:, username:, password:)
        log_connection(host, port, username, password)

        ::MQTT::Client.connect(host: host, port: port, username: username, password: password)
      end

      # Connects for the duration of the block and disconnects afterwards.
      def connect(host:, port:, username:, password:, &block)
        log_connection(host, port, username, password)

        ::MQTT::Client.connect(host: host, port: port, username: username, password: password, &block)
      end

      private

      def log_connection(host, port, username, password)
        logged_password = password.nil? || password.empty? ? "<NONE>" : "<REDACTED>"

        Dsmr2mqtt.logger.debug(
          "Connecting to MQTT broker at #{host}:#{port} using username #{username} and password #{logged_password}"
        )
      end
    end
  end
end
