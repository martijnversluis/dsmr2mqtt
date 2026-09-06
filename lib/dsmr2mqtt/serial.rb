# frozen_string_literal: true

module Dsmr2mqtt
  # Reads the P1 serial port and yields complete DSMR telegrams (from the "/"
  # header line up to and including the "!<crc>" trailer).
  #
  # An IO can be injected for testing; otherwise a rubyserial port is opened.
  class Serial
    TELEGRAM = %r{/[\s\S]*?![0-9A-Fa-f]{4}\r?\n}.freeze
    CHUNK_SIZE = 256
    MAX_BUFFER = 8192

    def initialize(port:, baud: 115_200, io: nil)
      @port = port
      @baud = baud
      @io = io
    end

    def each_telegram
      buffer = +""

      loop do
        chunk = read_chunk

        if chunk.nil? || chunk.empty?
          sleep(0.05)
          next
        end

        buffer << chunk

        while (match = TELEGRAM.match(buffer))
          yield match[0]
          buffer = match.post_match
        end

        buffer = buffer.byteslice(-MAX_BUFFER, MAX_BUFFER) || buffer if buffer.bytesize > MAX_BUFFER
      end
    end

    private

    attr_reader :port, :baud

    def read_chunk
      io.read(CHUNK_SIZE)
    end

    def io
      @io ||= begin
        require "rubyserial"
        Dsmr2mqtt.logger.info "Opening serial port #{port} at #{baud} baud"
        ::Serial.new(port, baud)
      end
    end
  end
end
