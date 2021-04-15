require "bit_array"
require "evdev"
require "keyleds"

require "./config"
require "./key_lookup"

APP_ID = 1_u8

GKEYS_ID = Keyleds::Strings::FEATURE_NAMES.key_for("gkeys")

private def get_keyleds(config_path = nil)
  search = Dir.glob("/dev/hidraw*")
  search.unshift(config_path) if config_path
  search.each do |path|
    # If invalid device, try the next path
    device = Keyleds::Device.new(path, APP_ID) rescue next
    device.feature_count.times do |i|
      # Make sure device supports G-keys so we don't get errors later on
      return {path, device} if device.feature_id(i.to_u8) == GKEYS_ID
    end
  end
  abort "No supported devices found!"
end

private def get_event(hidraw_path)
  File.read("/sys/class/hidraw/#{hidraw_path.split('/')[2]}/device/uevent") =~ /^HID_UNIQ=(.*?)$/m
  # Regex matches kernel ID, glob to find event handle
  Dir.glob("/dev/input/by-id/*#{$1}-event-kbd")[0]? ||
    abort "Could not find keyboard event handle, is your device initialized correctly?"
end

class Gkeybind::Daemon
  @config : Config
  @keyleds : Keyleds::Device
  @last_keys : BitArray
  @stopped = false
  @uinput : Evdev::UinputDevice

  def initialize(@config)
    lookup = KeyLookup.new(@config.keyboard_layout)

    @config.actions.each_value do |actions|
      actions.each do |a|
        if a.responds_to?(:init)
          a.init(lookup)
        end
      end
    end

    hidraw, @keyleds = get_keyleds(@config.device_path)
    @last_keys = BitArray.new(@keyleds.gkeys_count.to_i)

    # File handle is only necessary to copy attributes, can safely close immediately
    evdev = File.open(get_event(hidraw)) {|f| Evdev::Device.from_file(f)}
    evdev.name = "gkeybind virtual device"
    @uinput = Evdev::UinputDevice.new(evdev)
  end

  def start
    @keyleds.custom_gkeys(true)
    @keyleds.on_gkey do |type, keys|
      next unless type.gkey?

      @last_keys.zip(keys).each_with_index do |(last, current), i|
        # process keydown events
        if !last && current && (actions = @config.actions["g#{i + 1}"]?)
          spawn do
            actions.each(&.run(@uinput))
          end
        end
      end

      @last_keys = keys
    end

    until @stopped
      @keyleds.flush
      sleep @config.poll_rate.milliseconds
    end
  ensure
    @keyleds.custom_gkeys(false)
    @keyleds.close
  end

  def stop
    @stopped = true
  end
end
