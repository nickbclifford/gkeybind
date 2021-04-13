require "evdev"
require "yaml"

require "./key_lookup"
require "./utils"

module Gkeybind
  abstract class Action
    include YAML::Serializable
    include YAML::Serializable::Strict

    abstract def run(uinput : Evdev::UinputDevice)

    # Fake deserialization polymorphism
    def self.new(ctx : YAML::ParseContext, node : YAML::Nodes::Node)
      {% for type in @type.subclasses %}
        begin
          return {{type}}.new(ctx, node)
        rescue YAML::ParseException
          # Swallow exception, try the next one
        end
      {% end %}

      node.raise("Unable to find an action with the given parameters")
    end
  end

  class Delay < Action
    getter delay : UInt32 | Float64

    def run(uinput)
      sleep delay.seconds
    end
  end

  class LiteralText < Action
    getter text : String
    getter key_delay = 20

    @[YAML::Field(ignore: true)]
    @keys = [] of Array(Key)

    # Initialize on startup to avoid recalculating lookups every time
    def init(lookup : KeyLookup)
      @keys = text.chars.map {|c| lookup.from_char(c)}
    end

    def run(uinput)
      @keys.each do |key|
        sleep key_delay.milliseconds
        Utils.keys_updown(uinput, key)
      end
    end
  end

  class Keys < Action
    getter keys : String

    @[YAML::Field(ignore: true)]
    @codes = [] of Key

    # Initialize on startup in case we have bad names, then they'll fail fast
    def init(lookup : KeyLookup)
      @codes = keys.split('+').flat_map {|n| lookup.from_name(n)}
    end

    def run(uinput)
      Utils.keys_updown(uinput, @codes)
    end
  end

  class Command < Action
    getter command : String

    def run(uinput)
      Process.new(command, shell: true)
    end
  end
end
