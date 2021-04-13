require "evdev"
require "yaml"

require "./utils"

module Gkeybind
  abstract struct Action
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

  struct Delay < Action
    getter delay : UInt32 | Float64

    def run(uinput)
      sleep delay.seconds
    end
  end

  struct LiteralText < Action
    getter text : String

    def run(uinput)
      # TODO
    end
  end

  struct Keys < Action
    getter keys : String

    def run(uinput)
      codes = keys.split('+').map do |str|
        case str
        when /^\d$/
          str = "Key#{str}"
        when "Shift", "Ctrl", "Alt"
          str = "Left#{str.downcase}"
        end
        Key.parse(str)
      end
      Utils.keys_updown(uinput, codes)
    end
  end

  struct Command < Action
    getter command : String

    def run(uinput)
      Process.new(command, shell: true)
    end
  end
end
