require "bit_array"
require "evdev"
require "keyleds"

require "./config"

APP_ID = 1_u8

private def get_device(config_path = nil)
  search = Dir.glob("/dev/hidraw*")
  search.unshift(config_path) if config_path
  search.each do |path|
    return Keyleds::Device.new(path, APP_ID) rescue next
  end
  abort "No supported devices found!"
end

class Gkeybind::Daemon
  @config : Config
  @keyleds : Keyleds::Device
  @last_keys : BitArray
  @stopped = false
  @uinput : Evdev::UinputDevice

  def initialize(@config)
    @keyleds = get_device(@config.device_path)
    @last_keys = BitArray.new(@keyleds.gkeys_count.to_i)

    evdev = Evdev::Device.new
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
            actions.each(&.run)
          end
        end
      end

      @last_keys = keys
    end

    until @stopped
      @keyleds.flush
      sleep 5.milliseconds
    end
  ensure
    @keyleds.custom_gkeys(false)
    @keyleds.close
  end

  def stop
    @stopped = true
  end
end
