projectname:=$(notdir $(CURDIR))

slides: presentation.md template 
	bs export --output .	
	mv presentation.html $(projectname).html
.PHONY: slides

init:
	bs init
.PHONY: init

clean:
	rm -rf dist template $(projectname).html
.PHONY: clean

presentation.md template: init

serve:
	bs serve .
