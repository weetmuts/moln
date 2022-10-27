
all:
	echo "Done making."

PREFIX?=/usr/local

test:
	./moln -l
	./moln -lc

install:
	install moln $(PREFIX)/bin
	install -T moln_completion /etc/bash_completion.d/moln
	mkdir -p $(PREFIX)/share/man/man1
	gzip -v9 -n -c moln.1 > $(PREFIX)/share/man/man1/moln.1.gz
