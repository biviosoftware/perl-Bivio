# This makefile makes Form.pm files for PDF documents in various
# sub-directories.
.PHONEY:	clean

dirs := \
	F1065/Y1999 \
	F1065/Y2000 \
	F1065sk1/Y1999 \
	F1065sk1/Y2000

makefiles := $(dirs:=/GNUmakefile)

modules := \
	$(wildcard ../*.pm) \
	$(wildcard *.pm)



all:	makefiles
	for dir in $(dirs); \
	do \
		(cd $$dir; make); \
        done

makefiles:	$(makefiles)

$(makefiles):	makeMakefile.pl
	./makeMakefile.pl $(@D)

clean:
	for dir in $(dirs); \
	do \
		(cd $$dir; make clean); \
        done
	rm -f $(makefiles)
