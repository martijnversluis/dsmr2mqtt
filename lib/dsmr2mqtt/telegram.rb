# frozen_string_literal: true

module Dsmr2mqtt
  # Parses a raw DSMR P1 telegram into named values and validates its CRC16.
  #
  # A telegram looks like:
  #
  #   /XMX5LGBBFG10\r\n
  #   \r\n
  #   1-0:1.7.0(00.500*kW)\r\n
  #   1-0:21.7.0(00.200*kW)\r\n
  #   ...
  #   !A1B2\r\n
  #
  class Telegram
    OBIS_LINE = /^(\d-\d:\d+\.\d+\.\d+)\((.*)\)\s*$/.freeze

    # OBIS code => friendly field name. Power is in kW, current in A, voltage in V.
    MAPPING = {
      "1-0:1.7.0" => :power_import_kw,
      "1-0:2.7.0" => :power_export_kw,
      "1-0:21.7.0" => :l1_power_import_kw,
      "1-0:41.7.0" => :l2_power_import_kw,
      "1-0:61.7.0" => :l3_power_import_kw,
      "1-0:22.7.0" => :l1_power_export_kw,
      "1-0:42.7.0" => :l2_power_export_kw,
      "1-0:62.7.0" => :l3_power_export_kw,
      "1-0:31.7.0" => :l1_current_a,
      "1-0:51.7.0" => :l2_current_a,
      "1-0:71.7.0" => :l3_current_a,
      "1-0:32.7.0" => :l1_voltage_v,
      "1-0:52.7.0" => :l2_voltage_v,
      "1-0:72.7.0" => :l3_voltage_v,
      "1-0:1.8.1" => :energy_import_low_kwh,
      "1-0:1.8.2" => :energy_import_high_kwh,
      "1-0:2.8.1" => :energy_export_low_kwh,
      "1-0:2.8.2" => :energy_export_high_kwh
    }.freeze

    def self.parse(raw)
      new(raw)
    end

    def initialize(raw)
      @raw = raw.to_s
      @obis = extract_obis
    end

    attr_reader :raw, :obis

    # Every OBIS value present in the telegram, keyed by its raw OBIS code.
    def [](obis_code)
      obis[obis_code]
    end

    # The mapped, numeric fields we care about (only the ones present).
    def to_h
      MAPPING.each_with_object({}) do |(code, field), result|
        next unless obis.key?(code)

        result[field] = numeric(obis.fetch(code))
      end
    end

    # CRC16 (poly 0xA001) over the telegram from "/" up to and including "!",
    # compared against the 4 hex digits that follow the "!".
    def valid?
      bang_index = raw.index("!")
      return false if bang_index.nil?

      expected = raw[(bang_index + 1)..].to_s[0, 4]
      return false if expected.length < 4

      actual = format("%04X", self.class.crc16(raw[0..bang_index]))
      actual.casecmp?(expected)
    end

    def self.crc16(data)
      data.each_byte.reduce(0) do |crc, byte|
        crc ^= byte
        8.times { crc = crc.nobits?(1) ? (crc >> 1) : ((crc >> 1) ^ 0xA001) }
        crc
      end
    end

    private

    def extract_obis
      raw.each_line.each_with_object({}) do |line, result|
        match = OBIS_LINE.match(line)
        result[match[1]] = match[2] if match
      end
    end

    # "00.500*kW" => 0.5, "001*A" => 1.0, "000123.456*kWh" => 123.456
    def numeric(value)
      value.to_s.split("*").first.to_f
    end
  end
end
