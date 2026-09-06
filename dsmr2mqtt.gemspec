# frozen_string_literal: true

require_relative "lib/dsmr2mqtt/version"

Gem::Specification.new do |spec|
  spec.name = "dsmr2mqtt"
  spec.version = Dsmr2mqtt::VERSION
  spec.authors = ["Martijn Versluis"]
  spec.email = ["martijnversluis@users.noreply.github.com"]

  spec.summary = "Read a DSMR P1 smart meter over serial and publish it to MQTT."
  spec.homepage = "https://github.com/martijnversluis/dsmr2mqtt"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|github|rubocop))})
    end
  end

  spec.bindir = "bin"
  spec.executables = ["dsmr2mqtt"]
  spec.require_paths = ["lib"]

  spec.add_dependency "mqtt", "~> 0.6"
  spec.add_dependency "parallel", "~> 1.23"
  spec.add_dependency "rubyserial", "~> 0.6"
end
