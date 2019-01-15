# This Makefile is just for when you're hacking on chrono inside
# its repo. It'll build the octfiles and install them into inst/.
#
# This only works if the mkoctfile on your path is the mkoctfile from
# the Octave that you will be using! Otherwise your octfile may crash
# Octave. To make this work, pass MKOCTFILE=... as an option to your
# 'make' invocation.

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
