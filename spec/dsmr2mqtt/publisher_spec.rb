# frozen_string_literal: true

require "json"

RSpec.describe Dsmr2mqtt::Publisher do
  subject(:publisher) do
    described_class.new(
      host: "mqtt.test",
      port: 1883,
      username: nil,
      password: nil,
      topic_prefix: "home/p1"
    )
  end

  let(:client) { instance_spy("MQTT::Client") }

  before { allow(Dsmr2mqtt::Mqtt).to receive(:client).and_return(client) }

  describe "#publish" do
    let(:telegram) do
      instance_double(Dsmr2mqtt::Telegram, to_h: { power_import_kw: 0.5, l1_current_a: 1.0 }, valid?: true)
    end

    it "publishes a retained JSON message to the topic prefix" do
      publisher.publish(telegram)

      expect(client).to have_received(:publish) do |topic, payload, retain:|
        expect(topic).to eq("home/p1")
        expect(retain).to be(true)

        data = JSON.parse(payload)
        expect(data).to include("power_import_kw" => 0.5, "l1_current_a" => 1.0, "valid" => true)
        expect(data).to have_key("measured_at")
      end
    end

    it "reuses a single connection across publishes" do
      publisher.publish(telegram)
      publisher.publish(telegram)

      expect(Dsmr2mqtt::Mqtt).to have_received(:client).once
    end
  end

  describe "#publish_heartbeat" do
    it "publishes an alive message to the heartbeat topic" do
      publisher.publish_heartbeat

      expect(client).to have_received(:publish) do |topic, payload, retain:|
        expect(topic).to eq("home/p1/heartbeat")
        expect(retain).to be(true)
        expect(JSON.parse(payload)).to include("alive" => true)
      end
    end
  end
end
