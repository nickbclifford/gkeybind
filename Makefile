CRFLAGS ?= --release
SHARDS ?= shards
PREFIX ?= /usr/local

CONFIG_PATH := $(CONFIG_PREFIX)/etc/gkeybind.yml

bin/gkeybind: shard.yml src/*.cr
	$(SHARDS) build $(CRFLAGS)

.PHONY: clean
clean:
	rm -rf bin

.PHONY: install
install: bin/gkeybind
	install -Dm755 bin/gkeybind $(PREFIX)/bin/gkeybind
	[ -f $(CONFIG_PATH) ] || install -Dm644 default_config.yml $(CONFIG_PATH)