require "yaml"

module Gkeybind
  abstract struct Action
    include YAML::Serializable
    include YAML::Serializable::Strict

    abstract def run

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

    def run
      sleep delay.seconds
    end
  end

  struct LiteralText < Action
    getter text : String

    def run
      # TODO
    end
  end

  struct Keys < Action
    getter keys : String

    def run
      # TODO
    end
  end

  struct Command < Action
    getter command : String

    def run
      Process.new(command, shell: true)
    end
  end
end
