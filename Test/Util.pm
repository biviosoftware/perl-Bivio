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
    accept tests... - runs the tests (.btest) under Bivio::Test::Language
    unit tests/dirs... -- runs the tests (*.t) under Test::Harness

=cut

sub USAGE {
    return <<'EOF';
usage: b-test [options] command [args...]
commands:
    accept tests... - runs the tests (.btest) under Bivio::Test::Language
    unit tests/dirs... -- runs the tests (*.t) under Test::Harness
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

=head2 acceptance(string tests, ...)

Run acceptance tests.

=cut

sub acceptance {
    my($self) = @_;
    return;
}

=for html <a name="unit"></a>

=head2 unit(string test, ...)

Executes I<test>(s) by calling C<Test::Harness::runtests>.  I<test> may be
a directory or file name.  If it is a directory, all tests (C<*.t>) files
will be executed.  All tests must end in C<*.t>.

=cut

sub unit {
    my($self, $tests) = _find_files(\@_, 't');
    my($total_ok, $total_max) = (0, 0);
    _run($self, $tests, sub {
	my($self, $tests) = @_;
	foreach my $t (@$tests) {
	    my($max, $ok, $not_ok) = (0, 0, 0, 0);
	    $self->print(sprintf('%20s: ', $t));
	    _trace('running: ', $t) if $_TRACE;
	    foreach my $line (split(/\n/, ${$self->piped_exec("$^X -w $t 2>&1")})) {
		_trace($line) if $_TRACE;
		if ($max) {
		    $ok++ if $line =~ /^ok\s*(\d+)/;
		}
		elsif ($line =~ /^1\.\.(\d+)/) {
		    $max = $1;
		}
	    }
	    $self->print($ok == $max ? 'ok' : 'NOT OK', "\n");
	    $total_ok++ if $ok == $max;
	    $total_max++;
        }
    });
    unless ($total_max == $total_ok) {
	$self->print(
	    sprintf('FAILED %d (%.1f%%) and passed %d (%.1f%%)' . "\n",
		map {
		    ($_, 100 * $_ / $total_max);
		} ($total_max - $total_ok), $total_ok
	));
	Bivio::Die->throw_quietly('DIE');
        # DOES NOT RETURN
    }
    $self->print("All ($total_max) tests passed\n");
    return;
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
	    return unless $_ =~ /\.$pattern$/ && -r $_;
	    my(undef, $d, $f) = File::Spec->splitpath($_);
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
    foreach my $d (sort(keys(%$tests))) {
	$self->print("*** Entering: $d\n");
	Bivio::IO::File->chdir($d);
	&$action($self, $tests->{$d});
	$self->print("*** Leaving: $d\n\n");
    }
    return;
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.

=head1 VERSION

$Id$

=cut

1;
