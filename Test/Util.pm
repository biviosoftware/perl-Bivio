# Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.
# $Id$
package Bivio::Test::Util;
use strict;
$Bivio::Test::Util::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::Util::VERSION;

=head1 NAME

Bivio::Test::Util - runs and manages acceptance (.btest) and unit (.t) tests

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Test::Util;

=cut

=head1 EXTENDS

L<Bivio::ShellUtil>

=cut

use Bivio::ShellUtil;
@Bivio::Test::Util::ISA = ('Bivio::ShellUtil');

=head1 DESCRIPTION

C<Bivio::Test::Util> runs acceptance and unit tests.  A unit test is defined
using L<Bivio::Test|Bivio::Test>.  An acceptance test has its own language,
which is a subclass of L<Bivio::Test::Language|Bivio::Test::Language>.

=cut


=head1 CONSTANTS

=cut

=for html <a name="USAGE"></a>

=head2 USAGE : string

Returns:
 usage: b-test [options] command [args...]
 commands:
    acceptance tests/dirs... - runs the tests (*.btest) under Bivio::Test::Language
    unit tests/dirs... -- runs the tests (*.t) and print cummulative results

=cut

sub USAGE {
    return <<'EOF';
usage: b-test [options] command [args...]
commands:
    acceptance tests/dirs... - runs the tests (*.btest) under Bivio::Test::Language
    unit tests/dirs... -- runs the tests (*.t) and print cummulative results
EOF
}

#=IMPORTS
use Bivio::IO::Trace;
use Test::Harness ();
use Bivio::Test::Language;
use File::Find ();
use File::Spec ();
use Bivio::IO::File;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;

=head1 METHODS

=cut

=for html <a name="acceptance"></a>

=head2 acceptance(string test, ...) : string_ref

Executes I<test>(s) under L<Bivio::Test::Language|Bivio::Test::Language>.
I<test> may be a directory or file name.  If it is a directory, all tests
(C<*.btest>) files will be executed.  All tests must end in C<*.btest>.

When only one test is run, shows the output of the test.

=cut

sub acceptance {
    my($self, $tests) = _find_files(\@_, 'btest');
    return _run($self, $tests, sub {
        my($self, $test, $out) = @_;
	my($ok) = 0;
	foreach my $line (split(/\n/,
	    $$out = ${$self->piped_exec("$^X -w - 2>&1", <<"EOF", 1)})) {
use strict;
use Bivio::Test::Language;
print "1..1\n";
my(\$die) = Bivio::Test::Language->test_run(qw{$test});
print(\$die ? "not ok: " . \$die->as_string . "\n" : "1 ok\n");
EOF
            chomp($line);
            $ok++ if $line eq "1 ok";
	}
	return $ok;
    });
}

=for html <a name="unit"></a>

=head2 unit(string test, ...) : string_ref

Executes I<test>(s).  I<test> may be a directory or file name.  If it is a
directory, all tests (C<*.t>) files will be executed.  All tests must end in
C<*.t>.

When only one test is run, shows the output of the test.

=cut

sub unit {
    my($self, $tests) = _find_files(\@_, 't');
    return _run($self, $tests, sub {
        my($self, $test, $out) = @_;
	my($max, $ok) = (-1, 0);
	foreach my $line (split(/\n/,
	    $$out = ${$self->piped_exec("$^X -w $test 2>&1", undef, 1)})) {
	    chomp($line);
	    if ($max >= 0) {
		$ok++ if $line =~ /^ok\s*(\d+)/;
	    }
	    elsif ($line =~ /^1\.\.(\d+)/) {
		$max = $1;
	    }
	}
	return $ok == $max;
    });
}

#=PRIVATE METHODS

# _find_files(array_ref args, string pattern) : array
#
# Returns self, and hash of tests to run (dir, tests).
#
sub _find_files {
    my($args, $pattern) = @_;
    my($self) = shift(@$args);
    $self->usage_error('must supply test files or directories') unless @$args;
    my($tests) = {};
    my($pwd) = Bivio::IO::File->pwd;
    File::Find::find({
	no_chdir => 1,
	wanted => sub {
	    return
		unless $File::Find::name =~ /\.$pattern$/
		    && -r $File::Find::name;
	    my(undef, $d, $f) = File::Spec->splitpath($File::Find::name);
	    $d = File::Spec->rel2abs($d, $pwd);
	    push(@{$tests->{$d} ||= []}, $f);
	    return;
	}},
	@$args);
    return ($self, $tests);
}

# _run(self, hash_ref tests, code_ref action)
#
# Runs the tests with action.
#
sub _run {
    my($self, $tests, $action) = @_;
    my($ok, $max) = (0, 0);
    my($one_dir) = keys(%$tests) == 1;
    foreach my $t (values(%$tests)) {
	$max += @$t;
    }
    $self->usage_error('no tests found') unless $max;
    foreach my $d (sort(keys(%$tests))) {
	$self->print("*** Entering: $d\n") unless $one_dir;
	Bivio::IO::File->chdir($d);
	foreach my $t (@{$tests->{$d}}) {
	    $self->print(sprintf('%20s: ', $t));
	    my($res) = 'FAILED';
	    my($out);
	    if (&$action($self, $t, \$out)) {
		$res = 'PASSED';
		$ok++;
	    }
	    $self->print($res, "\n");
	    $out ||= '';
	    $out =~ s/^/  /mg;
	    if ($max == 1) {
		$self->print("Output:\n", $out);
	    }
        }
	$self->print("*** Leaving: $d\n\n") unless $one_dir;
    }
    unless ($max == $ok) {
	$self->print(
	    sprintf('FAILED %d (%.1f%%) and passed %d (%.1f%%)' . "\n",
		map {
		    ($_, 100 * $_ / $max);
		} ($max - $ok), $ok
	));
	Bivio::Die->throw_quietly('DIE');
        # DOES NOT RETURN
    }
    $self->print("All ($max) tests passed\n");
    return;
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.

=head1 VERSION

$Id$

=cut

1;
