# This makefile makes Form.pm files for PDF documents in various
# sub-directories.
.PHONEY:	clean

dirs := \
	f1065/y1999 \
	f1065sk1/y1999

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
