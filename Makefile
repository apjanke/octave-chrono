# This Makefile is just for when you're hacking on chrono inside
# its repo. It'll build the octfiles and install them into inst/.

MKOCTFILE ?= mkoctfile

.PHONY: all
all: local

.PHONY: local
local: src/__oct_time_binsearch__.cc
	$(MKOCTFILE) src/__oct_time_binsearch__.cc
	mv __oct_time_binsearch__.o __oct_time_binsearch__.oct inst/

.PHONY: clean
clean:
	rm -f *.oct *.o src/*.oct src/*.o inst/*.oct
