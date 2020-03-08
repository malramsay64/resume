

input=resume.tex
makedir=output

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

$(input:.tex=.pdf): $(input) preamble.tex $(folders) $(bibfile) | $(makedir)
	tectonic -o $(makedir) --keep-intermediates -r0 $<
	if [ -f $(makedir)/$(notdir $(<:.tex=.bcf)) ]; then biber --input-directory $(makedir) $(notdir $(<:.tex=)); fi
	tectonic -o $(makedir) --keep-intermediates -r1 $<
	cp $(makedir)/$(notdir $@) resume_Malcolm_Ramsay.pdf

%:letters/%.tex
	tectonic -o $(makedir) --keep-intermediates -r0 letters/$@.tex
	if [ -f $(makedir)/$(notdir $(<:.tex=.bcf)) ]; then biber --input-directory $(makedir) $(notdir $(<:.tex=)); fi
	tectonic -o $(makedir) --keep-intermediates -r1 $<
	mv $(output)/$@.pdf .

.PHONY:clean
clean:
	-rm -rf $(output)
	-rm -f $(input:.tex=.pdf)

clean-cache:
	rm -rf $$(biber --cache)

$(makedir):
	mkdir $(makedir)
	$(foreach f, $(folders), mkdir $(makedir)/$(f); )
