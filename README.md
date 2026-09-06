# dsmr2mqtt

Reads a DSMR P1 smart meter over a serial (USB) connection, parses the
telegrams and publishes them to MQTT as a single retained JSON message — plus a
heartbeat so downstream monitoring can spot a stalled reader.

Built to run on a small host (e.g. a Raspberry Pi) next to the meter, so the
per-phase power/current stream stays available independently of the rest of the
home automation stack.

## Installation

```ruby
gem "dsmr2mqtt"
```

or standalone:

```
gem install dsmr2mqtt
```

## Usage

Copy `config.example.yml` and point it at your serial port and MQTT broker:

```yaml
serial:
  port: /dev/ttyUSB0
  baud: 115200          # DSMR 5 = 115200, older meters = 9600
mqtt:
  host: mqtt.home
  port: 1883
  username: homy
  password: secret
  topic_prefix: home/p1
heartbeat_interval: 30
```

Run it:

```
dsmr2mqtt config.yml
```

Install as a systemd service that restarts automatically (needs root):

```
sudo dsmr2mqtt install /etc/dsmr2mqtt/config.yml
```

## Published payload

A retained JSON message on `topic_prefix`, e.g. `home/p1`:

```json
{
  "power_import_kw": 0.5,
  "power_export_kw": 0.0,
  "l1_power_import_kw": 0.2,
  "l2_power_import_kw": 0.15,
  "l3_power_import_kw": 0.15,
  "l1_current_a": 1.0,
  "l2_current_a": 2.0,
  "l3_current_a": 1.0,
  "l1_voltage_v": 230.1,
  "energy_import_low_kwh": 1234.567,
  "valid": true,
  "measured_at": "2026-09-06T20:00:00Z"
}
```

Only OBIS codes present in the telegram are included. Telegrams that fail their
CRC16 check are discarded and never published.

## Development

```
bin/setup
bundle exec rake spec
```

## License

MIT
