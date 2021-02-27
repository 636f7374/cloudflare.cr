SURVEYOR_OUT ?= bin/radar
SURVEYOR_SRC ?= cli.cr
SYSTEM_BIN ?= /usr/local/bin


install: build
	cp $(SURVEYOR_OUT) $(SYSTEM_BIN) && rm -f $(SURVEYOR_OUT)*
build: shard
	crystal build -Dpreview_mt $(SURVEYOR_SRC) -o $(SURVEYOR_OUT) --release
test: shard
	crystal spec
shard:
	shards build
clean:
	rm -f $(SURVEYOR_OUT)* && rm -rf lib && rm shard.lock