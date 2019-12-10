

input=resume.tex
output=.output

latex=pdflatex
bib=biber
bibfile=bibliography/publications.bib

empty=
space=$(empty) $(empty)

ifeq ($(bib), bibtex)
	bibcommand = ( cd $(output); $(bib) $(basename $(input)) )
else
	bibcommand = $(bib) $(output)/$(basename $(input))
endif

all: $(input:.tex=.pdf)

$(input:.tex=.pdf): $(input) preamble.tex $(folders) $(bibfile) | $(output)
	$(shell export TEXINPUTS=.:$(subst $(space),:,$(folders)))
	latexmk -pdf -xelatex -outdir=$(output) $(input)
	mv $(output)/$(input:.tex=.pdf) resume_Malcolm_Ramsay.pdf

%:letters/%.tex
	latexmk -pdf -xelatex -outdir=$(output) letters/$@.tex
	mv $(output)/$@.pdf .

.PHONY:clean
clean:
	-rm -rf $(output)
	-rm -f $(input:.tex=.pdf)

clean-cache:
	rm -rf $$(biber --cache)

$(output):
	mkdir $(output)
	$(foreach f, $(folders), mkdir $(output)/$(f); )
