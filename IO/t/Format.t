# -*-perl-*-
#
# $Id$
#
use strict;

BEGIN { $| = 1; print "1..5\n"; }
my($loaded) = 0;
END {print "not ok 1\n" unless $loaded;}
use Bivio::IO::Format;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.
use Bivio::ShellUtil;

my($T) = 2;
# t(string format, array_ref args, string top, string expected)
# t(Bivio::IO::Format format, string expected)
sub t {
    my($format, $args, $top, $expected) = @_;
    if (ref($format)) {
	$expected = $args;
    }
    else {
	$format = Bivio::IO::Format->new()->add_line($format, $args)
		->put_top($top)->process;
    }
    my($actual) = $format->get_result;
    print(defined($actual) && $$actual eq $expected
	    ? ("ok ", $T++, "\n")
	    : ("not ok ", $T++,
		"; actual = ", $$actual,
		"; expected = ", $expected,
		"; format = ", $format,
		"; args = ", ${Bivio::ShellUtil->ref_to_string($args)},
		"\n"));
}

# We don't want to bother with formfeeds in the strings
local($^L) = '';

t('very simple', [], 'TOP HERE', "TOP HERE\nvery simple\n");
my($v) = 'bla';
t(<<'FORMAT', [\$v], "TOP HERE\n", <<'RESULT');
very simple: @<<<<
FORMAT
TOP HERE
very simple: bla
RESULT

local($=) = 3;
t(<<'FORMAT', [\$v], "TOP HERE\n", <<'RESULT');
This is a long format
which goes over
three lines
@<<<<<
FORMAT
TOP HERE
This is a long format
which goes over
three lines
bla
RESULT

my($f) = Bivio::IO::Format->new()->add_line("hello:\n@<<<<", [\$v])
	->put_top('HERE');
# foreach statements change the reference "value" of the variable,
# so we can't just say "foreach $v (qw(a b c))", because the \$v above
# is going away for the duration of the foreach loop.
foreach my $x (qw(a b c)) {
    $v = $x;
    $f->process;
}
t($f, <<'RESULT');
HERE
hello:
a
HERE
hello:
b
HERE
hello:
c
RESULT
