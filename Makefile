

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

$(input:.tex=.pdf): $(input) $(folders) $(bibfile) | $(output)
	$(shell export TEXINPUTS=.:$(subst $(space),:,$(folders)))
	latexmk -pdf -outdir=$(output) $(input)
	mv $(output)/$(input:.tex=.pdf) .

%:letters/%.tex
	$(latex) $(pre_flags) $(pdf_flags) $<
	$(latex) $(pdf_flags) $<
	mv $(output)/$@.pdf .

.PHONY:clean
clean:
	-rm -rf $(output)
	-rm -f $(input:.tex=.pdf)
	-rm $(bibfile)

clean-cache:
	rm -rf $$(biber --cache)

$(output):
	mkdir $(output)
	$(foreach f, $(folders), mkdir $(output)/$(f); )
