#!/usr/bin/perl -w

# Build a GNUmakefile in a subdirectory.

use strict;

local($_);

unless (0 == $#ARGV) {
    die("usage: $0 <sub-directory>\n");
}

my($top) = '../' . $ARGV[0];
$top =~ s([^/]+)(..)g;

my($pdf, $junk) = split('/', $ARGV[0]);
$pdf .= '.pdf';

my($bivio_form) = 'Bivio::UI::PDF::Form';
my($class) = $bivio_form . '::' . $ARGV[0] . '::Form';
$class =~ s(/)(::)g;

my($parent) = $bivio_form . '::Form';

my(@modules) = `ls *.pm ../*.pm`;

my($xlator_set) = $class;
$xlator_set =~ s/Form$/XlatorSet/;

my($text);
while (<DATA>) {
    if (/top=/) {
	$text .= 'top=' . $top . "\n";
    }
    elsif (/pdf=/) {
	$text .= 'pdf=' . $pdf . "\n";
    }
    elsif (/modules=/) {
	$text .= 'modules= ';
	map {
	    chop;
	    $text .= " \\\n\t$_";
	} @modules;
	$text .="\n";
    }
    elsif (/class=/) {
	$text .= 'class=' . $class . "\n";
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

open(OUT, ">$ARGV[0]/GNUmakefile")
	or die("Can't open $ARGV[0]/GNUmakefile\n");
print(OUT $text);

1;

__DATA__
.PHONEY:	clean

top=
pdf=
class=
parent=
modules=
xlator_set=

form=$(top)/Form

deps= \
	$(addprefix $(form)/, $(modules)) \
	XlatorSet.pm \
	$(pdf)

Form.pm:	$(deps)
	$(form)/buildFormModule.pl $@ $(class) $(parent) $(pdf) $(xlator_set)

clean:
	rm -f Form.pm
