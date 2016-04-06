all:
	pdflatex nips2015.tex
	bibtex nips2015
	pdflatex nips2015.tex
	pdflatex nips2015.tex
