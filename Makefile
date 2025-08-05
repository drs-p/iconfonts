.PHONY: all install uninstall doc dist readme

TEXMFLOCAL = $(shell kpsewhich -expand-var '$$TEXMFHOME')
DOC_DIR = texmf/doc/latex/iconfonts
VERSION = $(shell git describe)

all: doc

install:
	cp -r texmf/doc texmf/fonts texmf/tex "$(TEXMFLOCAL)"
	texhash "$(TEXMFLOCAL)"

uninstall:
	-(cd "$(TEXMFLOCAL)"; rm -rf tex/latex/iconfonts fonts/opentype/fortawesome/fontawesome-free fonts/truetype/public/academicons doc/latex/iconfonts)
	find "$(TEXMFLOCAL)" -type d -and -empty -delete
	texhash "$(TEXMFLOCAL)"

doc: install
	cd $(DOC_DIR); make all
	-(cd "$(TEXMFLOCAL)"; rm -rf doc/latex/iconfonts)
	cp -r texmf/doc "$(TEXMFLOCAL)"
	texhash "$(TEXMFLOCAL)"

dist: doc
	mkdir -p dist
	rm -f dist/iconfonts-$(VERSION).zip
	zip -r dist/iconfonts-$(VERSION).zip texmf
