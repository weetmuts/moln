# Copyright (C) 2022-2023 Fredrik Öhrström (spdx: MIT)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

PREFIX?=/usr/local
SOURCES=$(sort $(wildcard src/*))

all: moln moln.html moln.pdf moln.1

moln: $(SOURCES)
	@rm -f moln
	@cat $(SOURCES) > moln
	@echo "exit 0" >> moln
	@echo "#TRANSFORMS" >> moln
	@tar czf transforms.tgz transforms
	@cat transforms.tgz >> moln
	@chmod a+x moln
	@echo "Built moln"

moln.1: moln moln_1_pre moln_1_post
	@cp moln_1_pre moln.1
	@./moln --output=man --list-help >> moln.1
	@cat moln_1_post >> moln.1
	@echo "Built moln.1"

moln.html: moln moln_htmq_pre moln_htmq_post xmq
	@cp moln_htmq_pre moln.htmq
	@./moln --output=htmq --list-help >> moln.htmq
	@cat moln_htmq_post >> moln.htmq
	@./xmq moln.htmq to-html > moln.html
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

test: xmq
	@./tests/test_basics.sh
	@if [ "$(CREDENTIALS_EXIST)" = "true" ]; then ./tests/test_with_credentials.sh ; fi

xmq:
	@mkdir -p build
	@(cd build; git clone --depth 1 https://github.com/libxmq/xmq.git)
	@(cd build/xmq; ./configure; make)
	@cp build/xmq/build/x86_64-pc-linux-gnu/release/xmq .

install:
	install moln $(PREFIX)/bin
	install -T moln_completion /etc/bash_completion.d/moln
	mkdir -p $(PREFIX)/share/man/man1
	gzip -v9 -n -c moln.1 > $(PREFIX)/share/man/man1/moln.1.gz

.PHONY: all test install
