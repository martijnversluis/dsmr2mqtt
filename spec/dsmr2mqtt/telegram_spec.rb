# frozen_string_literal: true

RSpec.describe Dsmr2mqtt::Telegram do
  # Body from "/" up to and including "!"; the CRC is computed over exactly this.
  let(:body) do
    [
      "/XMX5LGBBFG1009325044",
      "",
      "1-0:1.8.1(001234.567*kWh)",
      "1-0:2.8.1(000321.000*kWh)",
      "1-0:1.7.0(00.500*kW)",
      "1-0:2.7.0(00.000*kW)",
      "1-0:21.7.0(00.200*kW)",
      "1-0:41.7.0(00.150*kW)",
      "1-0:61.7.0(00.150*kW)",
      "1-0:31.7.0(001*A)",
      "1-0:51.7.0(002*A)",
      "1-0:71.7.0(001*A)",
      "1-0:32.7.0(230.1*V)",
      "!"
    ].join("\r\n")
  end

  let(:crc) { format("%04X", described_class.crc16(body)) }
  let(:raw) { "#{body}#{crc}\r\n" }

  describe "#to_h" do
    subject(:fields) { described_class.parse(raw).to_h }

    it "maps the actual power per phase in kW" do
      expect(fields).to include(
        power_import_kw: 0.5,
        l1_power_import_kw: 0.2,
        l2_power_import_kw: 0.15,
        l3_power_import_kw: 0.15
      )
    end

    it "maps the current per phase in A" do
      expect(fields).to include(l1_current_a: 1.0, l2_current_a: 2.0, l3_current_a: 1.0)
    end

    it "maps voltage and energy totals" do
      expect(fields).to include(
        l1_voltage_v: 230.1,
        energy_import_low_kwh: 1234.567,
        energy_export_low_kwh: 321.0
      )
    end

    it "omits OBIS codes that are not present" do
      expect(fields).not_to have_key(:l2_voltage_v)
    end
  end

  describe "#valid?" do
    it "is true when the CRC matches" do
      expect(described_class.parse(raw)).to be_valid
    end

    it "accepts a lowercase CRC" do
      expect(described_class.parse("#{body}#{crc.downcase}\r\n")).to be_valid
    end

    it "is false when the CRC is wrong" do
      expect(described_class.parse("#{body}0000\r\n")).not_to be_valid
    end

    it "is false when there is no trailer" do
      expect(described_class.parse("garbage without a bang")).not_to be_valid
    end
  end
end
