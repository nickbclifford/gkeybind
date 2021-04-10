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
	install bin/gkeybind $(PREFIX)/bin