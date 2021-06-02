input=resume.tex

all: $(input:.tex=.pdf)

$(input:.tex=.pdf): $(input) preamble.tex
	tectonic $<
	cp $@ resume_Malcolm_Ramsay.pdf

%:letters/%.tex
	tectonic letters/$@.tex
	mv $(output)/$@.pdf .

.PHONY:clean
clean:
	-rm -f $(input:.tex=.pdf)
