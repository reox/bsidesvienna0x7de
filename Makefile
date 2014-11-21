# -*- makefile -*-

# Assumes each *.slides-beamer.tex file is a file that will create
# both a Beamer slide file and a handout.  Should work for all files
# matching that pattern without any extra customisation.

# Copyright (C) 2005  Nick Urbanik <nicku@nicku.org>

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

#LATEX = latex --interaction=batchmode
#PDFLATEX = pdflatex --interaction=batchmode
LATEX = latex
PDFLATEX = pdflatex

#tex_slide_files =  $(filter-out gl2.101.1.slides.tex gl2.101.3.slides.tex gl2.101.5.slides.tex gl2.102.1.slides.tex gl2.102.3.slides.tex,$(wildcard *.slides.tex))
#tex_slide_files =  $(wildcard *.slides.tex)
#tex_slide_files = 102-5.tex $(wildcard *.slides.tex)

# beamer_slide_files = $(tex_slide_files:%.tex=%-beamer.tex)
# slides =             $(tex_slide_files:%.tex=%-beamer.pdf)
# handouts =           $(tex_slide_files:%.tex=%-beamer-handout.pdf)
# handouts_ps =        $(tex_slide_files:%.tex=%-beamer-handout.ps)
beamer_slide_files = $(wildcard *.slides-beamer.tex)
slides =             $(beamer_slide_files:%.tex=%.pdf)
handouts =           $(beamer_slide_files:%.tex=%-handout.pdf)
handouts_ps =        $(beamer_slide_files:%.tex=%-handout.ps)
transparencies =     $(beamer_slide_files:%.tex=%-trans.pdf)

gifs    = $(wildcard *.gif)
figures = $(wildcard *.fig)
epsfigs = $(figures:.fig=.eps) $(gifs:.gif=.eps)
pdffigs = $(figures:.fig=.pdf) $(gifs:.gif=.pdf)

all: message \
	$(slides) \
	$(handouts) \
	$(transparencies) \
	$(handouts_ps)

#	gl2-overview-beamer.pdf \
#	$(beamer_slide_files)

texfiles: $(beamer_slide_files)

$(slides): gl2.slide-header-beamer.tex Makefile $(pdffigs)

$(handouts): gl2.slide-header-beamer-handout.tex Makefile $(pdffigs)

$(transparencies): gl2.slide-header-beamer-trans.tex Makefile $(pdffigs)

$(handouts_ps): gl2.slide-header-beamer-handout.tex Makefile $(pdffigs)

trans: $(transparencies)

%-beamer.tex: %.tex
	@echo
	@echo \*
	@echo \* Preprocessing $< to $@
	@echo \*
	seminar-to-beamer.pl $< | ./fix-beamer-further.pl > $@

# %.pdf: gl2.slide-header-beamer.tex Makefile $(pdffigs)

%.pdf: %.tex
	@echo
	@echo \*
	@echo \* Compiling $<
	@echo \*
	$(PDFLATEX) $<
	@while ( grep "Rerun to get cross-references"                   \
			$(subst .tex,.log,$<) >/dev/null ); do          \
		echo '** Re-running LaTeX **';                          \
		$(PDFLATEX) $<;                                            \
	done

# %.dvi:  gl2.slide-header-beamer-handout.tex

# %.dvi: %.tex
# 	@echo
# 	@echo \*
# 	@echo \* Compiling $<
# 	@echo \*
# 	$(LATEX) $<
# 	@while ( grep "Rerun to get cross-references"                   \
# 			$(subst .tex,.log,$<) >/dev/null ); do          \
# 		echo '** Re-running LaTeX **';                          \
# 		$(LATEX) $<;                                            \
# 	done

#%-handout-a5.tex: %.tex Makefile.beamer gl2.slide-header-beamer-handout.tex

%-handout-a5.tex: Makefile.beamer gl2.slide-header-beamer-handout.tex

%-trans.tex: %.tex
	@echo
	@echo \*
	@echo \* Converting $< to $@
	@echo \*
	sed -e 's/^\\input{gl2.slide-header-beamer}/\\input{gl2.slide-header-beamer-trans}/' $< > $@

%-handout-a5.tex: %.tex
	@echo
	@echo \*
	@echo \* Converting $< to $@
	@echo \*
	sed -e 's/^\\documentclass\[\(.*\)\]{beamer}/\\documentclass[10pt,a5paper]{article}\% DO NOT EDIT---WILL BE OVERWRITTEN\n\\usepackage{beamerarticle,geometry,graphicx}\% DO NOT EDIT---WILL BE OVERWRITTEN\n\\geometry{margin=10mm,includehead,headheight=15pt,headsep=5mm}\% DO NOT EDIT---WILL BE OVERWRITTEN\n\\usepackage{fancyhdr}\% DO NOT EDIT---WILL BE OVERWRITTEN\n\\usepackage[breaklinks]{hyperref}\% DO NOT EDIT---WILL BE OVERWRITTEN\n/' -e 's/\\input{gl2.slide-header-beamer}/\\input{gl2.slide-header-beamer-handout}/' $< > $@

%-handout.ps: %-handout-a5.ps
	@echo
	@echo \*
	@echo \* Converting $< to $@
	@echo \*
	psnup -Pa5 -pa4 -2 $< $@

# %-handout-a5.ps: %-handout-a5.dvi
# 	@echo
# 	@echo \*
# 	@echo \* Converting $< to PostScript
# 	@echo \*
# 	dvips -Ppdf -D 600 -G0 -o $@ $<

# %-handout-a5.dvi: %-handout-a5.tex
# 	@echo
# 	@echo \*
# 	@echo \* Compiling $<
# 	@echo \*
# 	$(LATEX) $<
# 	@while ( grep "Rerun to get cross-references"                   \
# 			$(subst .tex,.log,$<) >/dev/null ); do          \
# 		echo '** Re-running LaTeX **';                          \
# 		$(LATEX) $<;                                            \
# 	done

lpr: $(handouts_ps)
	@echo
	@echo \*
	@echo \* Big print job
	@echo \* Printing $^
	@echo \*
	lpr $^

%.pdf: %.eps
	@echo
	@echo \*
	@echo \* Producing PDF for $<
	@echo \*
	epstopdf $<

%-handout-a5.ps: %-handout-a5.pdf
	@echo
	@echo \*
	@echo \* Producing PostScript for $<
	@echo \*
	pdftops $<

# %.ps: %.dvi 
# 	@echo
# 	@echo \*
# 	@echo \* Converting $< to PostScript
# 	@echo \*
# 	dvips -Ppdf -D 600 -G0 -o $@ $<

%.pdf: %.ps 
	@echo
	@echo \*
	@echo \* Converting $< to PDF
	@echo \*
	ps2pdf13 -dPDFsettings=/prepress $< $@

%.eps: %.fig
	@echo
	@echo \*
	@echo \* Producing $@ from $<
	@echo \*
	fig2dev -L eps $< $@

%.eps: %.gif
	@echo
	@echo \*
	@echo \* Producing EPS from $<
	@echo \*
	convert $< $@

message:
	@echo "In order to build slides you must have beamer installed"
	@echo "Please run 'apt-get install tetex-beamer' in Debian or"
	@echo "'yum install tetex-beamer' in Fedora or Red Hat, or"
	@echo "As appropriate for your distribution."

list:
	@echo beamer_slide_files:
	@echo $(beamer_slide_files)
	@echo slides:
	@echo $(slides)
	@echo handouts:
	@echo $(handouts)
	@echo handouts_ps:
	@echo $(handouts_ps)

tidy:
	rm -f *.log *.ps *.toc *.aux *.eepic *.bak *.lg *.out *.idx *~ \
	*.nav *.snm *.out *.vrb

clean:  tidy
	rm -f *.dvi *.pdf

# Stop overzealous deletion of intermediate files
.PRECIOUS: %.eps $(pdffigs) %.slides-beamer.tex

# %-handout-a5.tex
