# gkeybind

A Linux utility for binding custom behavior to Logitech keyboards.

## Dependencies

Requires [Crystal](https://crystal-lang.org/), [keyleds](https://github.com/keyleds/keyleds), and [libevdev](https://www.freedesktop.org/wiki/Software/libevdev/).

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
device_path: /dev/hidraw1

actions:
    # Currently, only G-keys are supported for binding.
    g1: 
        # Actions must be entered as a list.
        # They are executed sequentially upon keydown.
        - text: Hello world!              # Types literal text into the current active window.
        - command: echo test > ~/file.txt # Runs an arbitrary shell command.
    g2:
        - delay: 1                        # Waits for a number of seconds. (decimals supported)
        - keys: Shift+F6                  # Sends keystrokes to the current active window. Uses xdotool syntax.
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
