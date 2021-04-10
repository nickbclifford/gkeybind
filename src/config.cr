require "yaml"

require "./action"

struct Gkeybind::Config
  include YAML::Serializable
  include YAML::Serializable::Strict

  getter device_path : String
  getter actions : Hash(String, Array(Action))
end
