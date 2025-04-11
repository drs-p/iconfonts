.PHONY: all install doc dist readme

TEXMFLOCAL = $(shell kpsewhich -expand-var '$$TEXMFHOME')
DOC_DIR = texmf/doc/latex/iconfonts
VERSION = $(shell git describe)

all: doc

install:
	cp -r texmf/fonts texmf/tex "$(TEXMFLOCAL)"
	texhash "$(TEXMFLOCAL)"

doc: install
	cd $(DOC_DIR); make all
	cp -r texmf/doc "$(TEXMFLOCAL)"

dist: doc
	mkdir -p dist
	rm -f dist/iconfonts-$(VERSION).zip
	zip -r dist/iconfonts-$(VERSION).zip texmf
