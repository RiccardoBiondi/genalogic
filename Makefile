empty = /dev/null
filename = main.tex
output_name = main



all:
	latexmk -g -synctex=1 -bibtex -interaction=nonstopmode -file-line-error -pdf $(filename) -jobname=$(output_name) -pdflatex="lualatex --file-line-error --shell-escape --synctex=1"


.PHONY: clean
clean:
	rm -f $(output_name).blg 2> $(empty)
	rm -f $(output_name).log 2> $(empty)
	rm -f $(output_name).out 2> $(empty)
	rm -f $(output_name).fls 2> $(empty)
	rm -f $(output_name).synctex.gz 2> $(empty)

	rm -f $(output_name).aux 2> $(empty)
	rm -f $(output_name).bbl 2> $(empty)
	rm -f $(output_name).fdb_latexmk 2> $(empty)