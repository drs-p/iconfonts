.PHONY: all

PDFS = iconfonts.pdf
all:
	-rm $(PDFS)
	make $(PDFS)
	latexmk -c
	-rm iconfonts.hd

%.pdf: %.tex
	latexmk -norc -lualatex $<
