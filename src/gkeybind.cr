require "yaml"

require "./config"
require "./daemon"

module Gkeybind
  VERSION = "0.1.0"
end

File.open("#{ENV["HOME"]}/.config/gkeybind.yml") do |f|
  config = Gkeybind::Config.from_yaml(f)

  # TODO: better filtering
  if kv = config.actions.find {|(k, _)| !k.matches?(/^g\d+$/)}
    raise Exception.new(%(Found binding for "#{kv[0]}", only G-key bindings currently supported))
  end

  daemon = Gkeybind::Daemon.new(config)

  Signal::INT.trap { daemon.stop }

  daemon.start
end
