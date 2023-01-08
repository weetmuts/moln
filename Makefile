
PREFIX?=/usr/local
SOURCES=$(sort $(wildcard src/*))

all: moln moln.html moln.pdf moln.1

moln: $(SOURCES)
	@rm -f moln
	@cat $(SOURCES) > moln
	@chmod a+x moln
	@echo "Built moln"

moln.1: moln moln_1_pre moln_1_post
	@cp moln_1_pre moln.1
	@./moln --output=man --list-help >> moln.1
	@cat moln_1_post >> moln.1
	@echo "Built moln.1"

moln.html: moln moln_htmq_pre moln_htmq_post
	@cp moln_htmq_pre moln.htmq
	@./moln --output=htmq --list-help >> moln.htmq
	@cat moln_htmq_post >> moln.htmq
	@xmq moln.htmq > moln.html
	@echo "Built moln.html"

moln.tex: moln moln_tex_pre moln_tex_post
	@cp moln_tex_pre moln.tex
	@./moln --output=tex --list-help >> moln.tex
	@cat moln_tex_post >> moln.tex
	@cat moln.tex | sed 's/_/\\_/g' | sed 's/\$$/\\$$/g' > gurka
	@mv gurka moln.tex
	@echo "Built moln.tex"

moln.pdf: moln.tex
	@xelatex -interaction=batchmode  -halt-on-error moln.tex
	@echo "Built moln.pdf"

test:
	@./tests/test_basics.sh
	@if [ "$(CREDENTIALS_EXIST)" = "true" ]; then ./tests/test_with_credentials.sh ; fi

install:
	install moln $(PREFIX)/bin
	install -T moln_completion /etc/bash_completion.d/moln
	mkdir -p $(PREFIX)/share/man/man1
	gzip -v9 -n -c moln.1 > $(PREFIX)/share/man/man1/moln.1.gz

.PHONY: all test install
