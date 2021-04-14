require "option_parser"
require "yaml"

require "./config"
require "./daemon"

config_path = "/etc/gkeybind.yml"

OptionParser.parse do |parser|
  parser.banner = "Usage: gkeybind [options]"
  parser.on("-c FILE", "--config=FILE", "Specifies the config file to use") do |arg|
    config_path = arg
  end
  parser.on("-h", "--help", "Shows this help") do
    puts parser
    exit
  end
  parser.invalid_option do |flag|
    STDERR.puts "ERROR: #{flag} is not a valid option."
    STDERR.puts parser
    exit 64 # EX_USAGE
  end
end

begin
  config = File.open(config_path) {|f| Gkeybind::Config.from_yaml(f)}
rescue err : YAML::ParseException
  abort "Error parsing config! #{err}", 65 # EX_DATAERR
rescue File::NotFoundError
  abort "Unable to open config file #{config_path}!", 66 # EX_NOINPUT
end

daemon = Gkeybind::Daemon.new(config)

trap = ->(signal : Signal){ daemon.stop }

Signal::INT.trap(&trap)
Signal::TERM.trap(&trap)

daemon.start
