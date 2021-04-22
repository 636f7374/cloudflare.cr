CLOUDFLARE_OUT ?= bin/cloudflare
CLOUDFLARE_SRC ?= cli.cr
SYSTEM_BIN ?= /usr/local/bin


install: build
	cp $(CLOUDFLARE_OUT) $(SYSTEM_BIN) && rm -f $(CLOUDFLARE_OUT)*
build: shard
	crystal build -Dpreview_mt $(CLOUDFLARE_SRC) -o $(CLOUDFLARE_OUT) --release
test: shard
	crystal spec
shard:
	shards build
clean:
	rm -f $(CLOUDFLARE_OUT)* && rm -rf lib && rm shard.lock