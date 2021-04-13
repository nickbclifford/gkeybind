require "yaml"

require "./action"

struct Gkeybind::Config
  include YAML::Serializable
  include YAML::Serializable::Strict

  getter device_path : String?
  getter keyboard_layout : String?
  getter poll_rate = 10
  getter actions : Hash(String, Array(Action))
end
