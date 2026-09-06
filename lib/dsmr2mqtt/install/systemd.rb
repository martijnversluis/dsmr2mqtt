# frozen_string_literal: true

module Dsmr2mqtt
  module Install
    # Installs dsmr2mqtt as a systemd service that restarts automatically.
    #
    #   sudo dsmr2mqtt install /etc/dsmr2mqtt/config.yml
    #
    class Systemd
      SERVICE_NAME = "dsmr2mqtt"
      UNIT_PATH = "/etc/systemd/system/#{SERVICE_NAME}.service"

      def initialize(config_path:, executable: default_executable, out: $stdout)
        @config_path = config_path
        @executable = executable
        @out = out
      end

      def run!
        write_unit
        systemctl("daemon-reload")
        systemctl("enable", SERVICE_NAME)
        systemctl("restart", SERVICE_NAME)
        out.puts "Installed and started #{SERVICE_NAME}. Check it with: journalctl -u #{SERVICE_NAME} -f"
      end

      def unit
        <<~UNIT
          [Unit]
          Description=DSMR P1 to MQTT bridge
          After=network-online.target
          Wants=network-online.target

          [Service]
          ExecStart=#{executable} #{config_path}
          Restart=always
          RestartSec=5

          [Install]
          WantedBy=multi-user.target
        UNIT
      end

      private

      attr_reader :config_path, :executable, :out

      def write_unit
        out.puts "Writing #{UNIT_PATH}"
        File.write(UNIT_PATH, unit)
      end

      def systemctl(*args)
        system("systemctl", *args) || raise("`systemctl #{args.join(' ')}` failed")
      end

      def default_executable
        File.expand_path($PROGRAM_NAME)
      end
    end
  end
end
