#!/usr/bin/perl -w

# Build a GNUmakefile in a subdirectory.

use strict;

local($_);

unless (0 == $#ARGV) {
    die("usage: $0 <sub-directory>\n");
}

my($dir) = $ARGV[0];
$dir =~ s(/$)();

my($top) = '../' . $dir;
$top =~ s([^/]+)(..)g;

my(@pdfs) = `ls $dir/*.pdf`;

my($bivio_form) = 'Bivio::UI::PDF::Form';

my($class_prefix) = $bivio_form . '::' . $dir . '::Form';
$class_prefix =~ s(/)(::)g;

my($parent) = $bivio_form . '::Form';

my(@modules) = `ls *.pm ../*.pm`;

my($xlator_set) = $class_prefix;
$xlator_set =~ s/Form$/XlatorSet/;

my($text);
while (<DATA>) {
    if (/top=/) {
	$text .= 'top=' . $top . "\n";
    }
    elsif (/forms=/) {
	$text .= 'forms=';
	map {
	    chop;
	    s(.*/)();
	    s/\.pdf//;
	    $text .= ' Form' . $_ . '.pm';
	} @pdfs;
	$text .= "\n";
    }
    elsif (/modules=/) {
	$text .= 'modules= ';
	map {
	    chop;
	    $text .= " \\\n\t$_";
	} @modules;
	$text .="\n";
    }
    elsif (/class_prefix=/) {
	$text .= 'class_prefix=' . $class_prefix . "\n";
    }
    elsif (/parent=/) {
	$text .= 'parent=' . $parent . "\n";
    }
    elsif (/xlator_set=/) {
	$text .= 'xlator_set=' . $xlator_set . "\n";
    }
    else {
	$text .= $_;
    }
}

open(OUT, ">$dir/GNUmakefile")
	or die("Can't open $dir/GNUmakefile\n");
print(OUT $text);

1;

__DATA__
.PHONEY:	clean

top=
forms=
class_prefix=
parent=
modules=
xlator_set=

deps= \
	$(addprefix $(top)/Form/, $(modules)) \
	XlatorSet.pm \
	$(pdfs)

Form%.pm : %.pdf
	$(top)/Form/buildFormModule.pl $@ $(class_prefix)$* $(parent) $< $(xlator_set)

all:	$(forms)

$(forms):	$(deps)

clean:
	rm -f $(forms)
