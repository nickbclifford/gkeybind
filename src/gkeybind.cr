require "option_parser"
require "yaml"

require "./config"
require "./daemon"

config_path = nil

OptionParser.parse do |parser|
  parser.banner = "Usage: gkeybind [options]"
  parser.on("-c FILE", "--config=FILE", "Specifies the config file to use") do |arg|
    config_path = arg
  end
  parser.on("-h", "--help", "Shows this help") do
    puts parser
    exit
  end
end

# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
base_dirs = (ENV["XDG_CONFIG_DIRS"]? || "/etc/xdg").split(':').unshift(ENV["XDG_CONFIG_HOME"]? || "#{ENV["HOME"]}/.config")

config_path ||= base_dirs.map {|d| "#{d}/gkeybind.yml"}.find {|p| File.exists?(p)}
abort "No config file found!" unless config_path

begin
  config = File.open(config_path.not_nil!) {|f| Gkeybind::Config.from_yaml(f)}
rescue err : YAML::ParseException
  abort "Error parsing config! #{err}"
end

daemon = Gkeybind::Daemon.new(config)

trap = ->(signal : Signal){ daemon.stop }

Signal::INT.trap(&trap)
Signal::TERM.trap(&trap)

daemon.start
