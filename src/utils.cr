require "evdev"

module Gkeybind
  alias Key = Evdev::Codes::Key

  module Utils
    def self.keys_updown(uinput : Evdev::UinputDevice, keys : Array(Key))
      keys.each do |key|
        uinput.write_event(key, 1)
      end
      uinput.write_event(Evdev::Codes::Syn::Report, 0)
      keys.reverse.each do |key|
        uinput.write_event(key, 0)
      end
      uinput.write_event(Evdev::Codes::Syn::Report, 0)
    end
  end
end
