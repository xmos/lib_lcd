ODGS = $(wildcard *.odg)
PDFS = $(ODGS:.odg=.pdf)

all: $(PDFS)
	@echo PDFs created

_uncropped:
	mkdir _uncropped

_uncropped/%.pdf: %.odg | _uncropped
	soffice -env:UserInstallation=file:///home/$(USER)/.libreoffice-alt --headless --convert-to pdf $< --outdir _uncropped

%.pdf: _uncropped/%.pdf
	pdfcrop $< $@

wavedrom:
	WaveDromEditor source horizontal_timing.js png horizontal_timing.png
	WaveDromEditor source vertical_timing.js png vertical_timing.png

clean:
	-rm $(PDFS)
	-rm _uncropped/*.pdf
	-rmdir _uncropped
