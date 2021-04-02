RADAR_OUT ?= bin/radar
RADAR_SRC ?= cli.cr
SYSTEM_BIN ?= /usr/local/bin


install: build
	cp $(RADAR_OUT) $(SYSTEM_BIN) && rm -f $(RADAR_OUT)*
build: shard
	crystal build -Dpreview_mt $(RADAR_SRC) -o $(RADAR_OUT) --release
test: shard
	crystal spec
shard:
	shards build
clean:
	rm -f $(RADAR_OUT)* && rm -rf lib && rm shard.lock