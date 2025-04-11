.PHONY: all

all: iconfonts.pdf
	latexmk -c
	-rm iconfonts.hd

%.pdf: %.tex
	latexmk -norc -lualatex $<
