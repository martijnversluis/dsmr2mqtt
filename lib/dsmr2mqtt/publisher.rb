# frozen_string_literal: true

require "json"
require "time"

module Dsmr2mqtt
  # Publishes parsed telegrams to MQTT as a single retained JSON message, plus
  # a heartbeat so downstream monitoring can detect a stalled reader.
  class Publisher
    def initialize(host:, port:, username:, password:, topic_prefix:)
      @mqtt_config = { host: host, port: port, username: username, password: password }
      @topic_prefix = topic_prefix
    end

    def publish(telegram)
      payload = telegram.to_h.merge(
        valid: telegram.valid?,
        measured_at: now.utc.iso8601
      )

      publish_json(topic_prefix, payload)
      Dsmr2mqtt.logger.debug "Published telegram to #{topic_prefix}"
    end

    def publish_heartbeat
      publish_json("#{topic_prefix}/heartbeat", alive: true, at: now.utc.iso8601)
    end

    private

    attr_reader :mqtt_config, :topic_prefix

    def publish_json(topic, payload)
      client.publish(topic, JSON.generate(payload), true)
    rescue ::MQTT::Exception, SystemCallError, IOError => e
      Dsmr2mqtt.logger.warn "MQTT publish failed (#{e.class}: #{e.message}); reconnecting next time"
      reset_client!
      raise
    end

    def client
      @client ||= Mqtt.client(**mqtt_config)
    end

    def reset_client!
      @client&.disconnect
    rescue StandardError
      nil
    ensure
      @client = nil
    end

    def now
      Time.now
    end
  end
end
