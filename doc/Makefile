# Makefile for Chrono documentation
#
# This setup uses the convention that "*.txi" files are the human-editable
# input files, and corresponding "*.texi" files are processed intermediate
# files.

DVIPS = dvips
LN_S = ln -s
OCTAVE = octave
PERL = perl
# On Mac, prefer Homebrew-installed Texinfo, because the system one is
# outdated. We need to explicitly pull it in because Homebrew does not 
# put it on the path by default.
# TODO: Replace "/usr/local" with a "brew --prefix" test.
ifeq ($(wildcard /usr/local/opt/texinfo/bin/makeinfo),)
	MAKEINFO = makeinfo
	TEXI2DVI = texi2dvi
	TEXI2HTML = makeinfo --html
	TEXI2PDF = texi2pdf
else
	MAKEINFO = /usr/local/opt/texinfo/bin/makeinfo
	TEXI2DVI = /usr/local/opt/texinfo/bin/texi2dvi
	TEXI2HTML = /usr/local/opt/texinfo/bin/makeinfo --html
	TEXI2PDF = /usr/local/opt/texinfo/bin/texi2pdf
endif

INFODOC = chrono.info
DVIDOC = $(patsubst %.info,%.dvi,$(INFODOC))
PSDOC = $(patsubst %.info,%.ps,$(INFODOC))
PDFDOC = $(patsubst %.info,%.pdf,$(INFODOC))
HTMLDOC = $(patsubst %.info,%.html,$(INFODOC))
TEXIDOC = $(patsubst %.info,%.texi,$(INFODOC))
DOCSTRINGS = DOCSTRINGS
INDEX = ../INDEX

default: all
all: info html pdf
info: $(INFODOC)
dvi: $(DVIDOC)
html: $(HTMLDOC)
pdf: $(PDFDOC)
ps: $(PSDOC)

%.dvi: %.texi
	$(TEXI2DVI) --clean -o $@ $<

%.info: %.texi
	$(MAKEINFO) --no-split -o $@ $<

%.pdf: %.texi
	$(TEXI2PDF) --clean -o $@ $<

%.ps: %.dvi
	$(DVIPS) -o $@ $<

%.html: %.texi
	rm -rf $(@:.html=.htp)
	if $(TEXI2HTML) -o $(@:.html=.htp) $<; then \
	  rm -rf $@ && mv $(@:.html=.htp) $@; \
	else \
	  rm -rf $(@:.html=.htp); exit 1; \
	fi

.PRECIOUS: %.texi
%.texi : %.txi
	@echo "Making texinfo $@"; \
	$(RM) -f $(DOCSTRINGS); \
	$(PERL) ./mkdoc.pl ../ > $(DOCSTRINGS); \
	$(PERL) ./mktexi.pl $< $(DOCSTRINGS) $(INDEX) > $@ ; \
	$(RM) -f $(DOCSTRINGS);

# Auxiliary make file defines build rules for generated images for the manual
-include images.mk
images.mk: images.sh
	$(SHELL) $< > $@

$(DVIDOC): $(IMAGES_EPS)
$(PDFDOC): $(IMAGES_PDF)

HTMLDIR_IMAGES = $(addprefix $(HTMLDOC)/,$(IMAGES_PNG))
$(HTMLDIR_IMAGES): $(IMAGES_PNG) | $(HTMLDOC)
	cp $(@F) $@

html: $(HTMLDIR_IMAGES)

# The images included in the HTML manual must be present before the makeinfo
# command is invoked or it will fall back on incorrect file names.
$(HTMLDOC): $(IMAGES_PNG)

# The texi2dvi script (used to create both PDF and DVI output formats)
# uses some fixed temporary file names.  In order to avoid a race condition
# the DVI and PDF builds are forced to run serially through a Makefile rule.
$(PDFDOC): $(DVIDOC)

clean:
	rm -rf *.bak *.dvi *.eps *.html *.info *.pdf *.ps *.png *.texi images.mk

.PHONY: default all clean dvi html info pdf ps
