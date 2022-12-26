
PREFIX?=/usr/local
SOURCES=$(sort $(wildcard src/*))

all: moln moln.1

moln: $(SOURCES)
	cat $(SOURCES) > moln

moln.1: moln moln_1_pre moln_1_post
	cp moln_1_pre moln.1
	cat moln_1_post >> moln.1

test:
	./moln -l
	./moln -lc

install:
	install moln $(PREFIX)/bin
	install -T moln_completion /etc/bash_completion.d/moln
	mkdir -p $(PREFIX)/share/man/man1
	gzip -v9 -n -c moln.1 > $(PREFIX)/share/man/man1/moln.1.gz

.PHONY: all test install
