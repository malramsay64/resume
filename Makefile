

input=resume.tex
output=.output

latex=xelatex
bib=biber
pdf_flags=--output-dir=$(output) #--shell-escape
pre_flags=-draftmode
master_bibfile:=../publications.bib
master_bibfile:=$(shell if [ -e $(master_bibfile) ]; then echo $(master_bibfile); fi)
bibfile=bibliography/publications.bib
abbrev=false

empty=
space=$(empty) $(empty)

ifeq ($(bib), bibtex)
	bibcommand = ( cd $(output); $(bib) $(basename $(input)) )
else
	bibcommand = $(bib) $(output)/$(basename $(input))
endif

all: $(input:.tex=.pdf)

bib: $(bibfile)

$(input:.tex=.pdf): $(input) $(folders) $(bibfile) | $(output)
	$(shell export TEXINPUTS=.:$(subst $(space),:,$(folders)))
	$(latex) $(pre_flags) $(pdf_flags) $(input)
	$(bibcommand)
	$(latex) $(pre_flags) $(pdf_flags) $(input)
	$(latex) $(pdf_flags) $(input)
	mv $(output)/$(input:.tex=.pdf) .

$(bibfile): $(master_bibfile) bibliography/convert.py bibliography/journals.txt
	( cd bibliography; python convert.py ../$(master_bibfile) $(abbrev))

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
