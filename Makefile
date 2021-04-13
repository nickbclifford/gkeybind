CRFLAGS ?= --release
SHARDS ?= shards
PREFIX ?= /usr/local

bin/gkeybind: shard.yml src/*.cr
	$(SHARDS) build $(CRFLAGS)

.PHONY: clean
clean:
	rm -rf bin

.PHONY: install
install: bin/gkeybind
	install -Dm755 bin/gkeybind $(PREFIX)/bin/gkeybind
	install -Dm644 default_config.yml $(CONFIG_PREFIX)/etc/gkeybind.yml