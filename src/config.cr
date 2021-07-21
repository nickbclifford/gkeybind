require "yaml"

require "./action"

struct Gkeybind::Config
  include YAML::Serializable
  include YAML::Serializable::Strict

  alias LayoutFile = {file: String}

  struct LayoutNames
    include YAML::Serializable

    {% for field in %w(rules model layout variant options) %}
      getter {{field.id}} = ""
    {% end %}
  end

  alias Layout = String | LayoutNames | LayoutFile

  getter device_path : String?
  getter keyboard_layout : Layout?
  getter poll_rate = 10
  getter actions : Hash(String, Array(Action))
end
