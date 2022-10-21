
all:
	echo "Done making."

PREFIX?=/usr/local

install:
	install moln $(PREFIX)/bin
	install -T moln_completion /etc/bash_completion.d/moln
