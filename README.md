# gkeybind

A Linux utility for binding custom behavior to Logitech keyboards.

## Dependencies

Requires [Crystal](https://crystal-lang.org/), [keyleds](https://github.com/keyleds/keyleds), [libevdev](https://www.freedesktop.org/wiki/Software/libevdev/), and [libxkbcommon](https://xkbcommon.org/).

## Installation

Run `make` to build, and `sudo make install` to install globally.
The `PREFIX` variable is supported to change the installation location (installs to `/usr/local` by default).

## Usage

TODO

### Config

`gkeybind` requires a config file, `gkeybind.yml`, in order to configure custom key behavior.

TODO

The file schema is as follows:
```yaml
# The desired device's HID file path.
# By default, gkeybind will use the first valid device found. Specify this field if disambiguation is necessary.
device_path: /dev/hidraw1

# By default, gkeybind will use the system default layout. Specify if detection does not work.
keyboard_layout: us

# By default, gkeybind will poll for new G-key events every 10ms to keep idle CPU usage low. Adjust to your preference.
poll_rate: 10

actions:
    # Currently, only G-keys are supported for binding.
    g1: 
        # Actions must be entered as a list.
        # They are executed sequentially upon keydown.

        # Types literal text.
        # Optionally, specify the delay in ms between each char being entered in case your applications get overwhelmed.
        - text: Hello world!  
          char_delay: 20
          
        # Runs an arbitrary shell command.
        - command: echo test > file.txt

    g2:
        # Waits for a number of seconds. (decimals supported)
        - delay: 1

        # Sends a direct sequence of keys. (case-sensitive, separated by +)
        # Use the `xkbcli` tool to find specific key names.
        - keys: Shift_L+F6
```

Requests for more action types are welcome!

## Contributing

1. Fork it (<https://github.com/nickbclifford/gkeybind/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Nick Clifford](https://github.com/nickbclifford) - creator and maintainer
