CRFLAGS ?= --release
SHARDS ?= shards
PREFIX ?= /usr/local

XDG_AUTOSTART ?= /etc/xdg/autostart

bin/gkeybind: shard.yml src/*.cr
	$(SHARDS) build $(CRFLAGS)

.PHONY: clean
clean:
	rm -rf bin

.PHONY: install
install: bin/gkeybind
	install -Dm755 bin/gkeybind $(PREFIX)/bin

.PHONY: autostart
autostart:
	install -Dm644 gkeybind.desktop $(XDG_AUTOSTART)