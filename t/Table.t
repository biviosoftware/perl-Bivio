# -*-perl-*-
#
# $Id$
#
use strict;

BEGIN { $| = 1; print "1..2\n"; }
my($loaded) = 0;
END {print "not ok 1\n" unless $loaded;}
use Bivio::Club::Table;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

sub weblint ($$) {
    my($test) = shift;
    my($html) = shift;
    my($ok) = 'ok ' . $test. "\n";
    my($file) = "Table.t$test.html";
    open(OUT, ">$file") || die("$file: $!");
    $html->[0] =~ s/<table/<table border=1/;
    print OUT '<html><head><title>X</title></head><body>',
	@$html, '</body></html>';
    close(OUT);
    print "Wrote $file\n";
    open(WEBLINT_IN, 'weblint -x Microsoft $file|') || die("weblint: $!");
    my(@weblint) = <WEBLINT_IN>;
    close(WEBLINT_IN) && !@weblint && ((print $ok), return);
    print @weblint, 'not ', $ok;
}
################################################################

my($t) = Bivio::Club::Table->new();
$t->add_column('One', 'number');
$t->add_column('Two', 'string');
$t->add_column('Three', 'email');
$t->add_column('Four', 'uri');
$t->add_column('Five', 'uri_list');
$t->add_column('Six', 'left');
$t->add_column('Seven', 'center');
$t->add_column('Eight', 'right');

my($html) = $t->render_html('My First Table',
[
  ['1.0',
   'a string here',   'nagler@bivio.com',
   'http://yahoo.com',
   [['http://yahoo.com', 'yahoo'],
    ['http://excite.com', 'excite'],
    ['http://lycos.com', 'lycos'],
   ],
   'left',
   'center & middle',
   'right',
  ]
]);
&weblint(2, $html);

################################################################

$t = Bivio::Club::Table->new(undef, 'spreadsheet');
$t->begin_column_group();
$t->add_column('1a', 'left');
$t->add_column('1b', 'left');
$t->add_column('1c', 'left');
$t->end_column_group();
$t->add_column('2', 'right');
$t->add_column('3', 'right');
$t->begin_column_group();
$t->add_column('4a', 'center');
$t->add_column('4b', 'center');
$t->end_column_group();

$html = $t->render_html('My Second Table',
[
  ['1.1a', '1.1b', '1.1c', '1.2', '1.3', '1.4a', '1.4b'],
  ['2.1a', undef, '2.1c', '2.2', undef, '2.4a', undef],
  ['3.1a', '3.1b', '3.1c', '3.2', '3.3'],
  [],
  ['5.1a'],
  "this string should span all cols",
]);
&weblint(3, $html);

################################################################
$t = Bivio::Club::Table->new([
    ['Col1', 'string'],
    ['Col2', [
        ['Subcol2a', 'uri'],
        ['Subcol2b', 'email'],
    ]]
]);

$html = $t->render_html('My Third Table',
[
  ['1.1a', 'http://www.olsen.ch', 'nagler@olsen.ch'],
]);
&weblint(4, $html);

