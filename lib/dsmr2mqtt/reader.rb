# frozen_string_literal: true

require "time"

module Dsmr2mqtt
  # Reads telegrams from a serial source, validates them and publishes each one
  # to MQTT, with a periodic heartbeat.
  class Reader
    def initialize(serial:, publisher:, heartbeat_interval: 30)
      @serial = serial
      @publisher = publisher
      @heartbeat_interval = heartbeat_interval
      @last_heartbeat_at = nil
    end

    def run!
      Dsmr2mqtt.logger.info "Starting DSMR reader"

      serial.each_telegram do |raw|
        telegram = Telegram.parse(raw)

        unless telegram.valid?
          Dsmr2mqtt.logger.warn "Discarding telegram with invalid CRC"
          next
        end

        publisher.publish(telegram)
        publish_heartbeat_if_due
      end
    end

    private

    attr_reader :serial, :publisher, :heartbeat_interval, :last_heartbeat_at

    def publish_heartbeat_if_due
      now = Time.now
      return if last_heartbeat_at && (now - last_heartbeat_at) < heartbeat_interval

      publisher.publish_heartbeat
      @last_heartbeat_at = now
    end
  end
end
