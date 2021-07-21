require "log"
require "option_parser"
require "yaml"

require "./config"
require "./daemon"
require "./utils"

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
  parser.on("-v", "--verbose", "Enables debug output") do
    Log.setup(:debug)
  end

  parser.invalid_option do |flag|
    STDERR.puts "ERROR: #{flag} is not a valid option."
    STDERR.puts parser
    exit 64 # EX_USAGE
  end
end

begin
  Log.debug { "Opening and parsing config at #{config_path}" }
  config = File.open(config_path) { |f| Gkeybind::Config.from_yaml(f) }
rescue err : YAML::ParseException
  Log.fatal(exception: err) { "Error parsing config!" }
  exit 65 # EX_DATAERR
rescue File::NotFoundError
  abort_log "Unable to open config file #{config_path}!", 66 # EX_NOINPUT
end

begin
  daemon = Gkeybind::Daemon.new(config)
rescue err
  Log.fatal(exception: err) { "Failed to initialize gkeybind!" }
  exit 65
end

trap = ->(signal : Signal) { daemon.stop }

Signal::INT.trap(&trap)
Signal::TERM.trap(&trap)

Log.info { "Starting gkeybind with #{config.actions.size} G-key listeners." }

daemon.start
