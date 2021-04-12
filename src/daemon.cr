require "bit_array"
require "keyleds"

require "./config"

class Gkeybind::Daemon
  APP_ID = 1_u8

  @config : Config
  @device : Keyleds::Device
  @last_keys : BitArray
  @stopped = false

  def initialize(@config)
    @device = Keyleds::Device.new(config.device_path, APP_ID)
    @last_keys = BitArray.new(@device.gkeys_count.to_i)
  end

  def start
    @device.custom_gkeys(true)
    @device.on_gkey do |type, keys|
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
      @device.flush
      sleep 5.milliseconds
    end
  ensure
    @device.custom_gkeys(false)
    @device.close
  end

  def stop
    @stopped = true
  end
end
