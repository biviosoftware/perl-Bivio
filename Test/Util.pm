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

Returns usage.

=cut

sub USAGE {
    return <<'EOF';
usage: b-test [options] command [args...]
commands:
    acceptance tests/dirs... - runs the tests (*.btest) under Bivio::Test::Language
    mock_sendmail -ffrom@email.com recipient1,recipient2,... -- bypasses MTA for acceptance tests
    nightly -- runs all acceptance tests with current tests from CVS
    task name query path_info -- executes task in context supplied returns output
    unit tests/dirs... -- runs the tests (*.t) and print cummulative results
EOF
}

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::Die;
use Bivio::IO::Config;
use Bivio::IO::File;
use Bivio::IO::Trace;
use Bivio::Test::Language;
use Bivio::Test;
use Bivio::Type::DateTime;
use File::Find ();
use File::Spec ();

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
use vars ('$_TRACE');
Bivio::IO::Trace->register;
Bivio::IO::Config->register({
    nightly_output_dir => '/tmp/test-run',
    nightly_cvs_dir => 'perl/Bivio',
});
my($_CFG);
my($_DT) = Bivio::Type->get_instance('DateTime');

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
	_piped_exec($self, '-', <<"EOF", $out,
use strict;
use Bivio::Test::Language;
print "1..1\n";
my(\$die) = Bivio::Test::Language->test_run(qw{$test});
print(\$die ? "1 not ok: " . \$die->as_string . "\n" : "1 ok\n");
EOF
	    sub {
		my($line) = @_;
		$ok++ if $line eq "1 ok";
	    },
	);
	return $ok;
    });
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item nightly_output_dir : string ['/tmp/test-run'],

Root directory of the run.  A subdirectory will be created with the timestamp
of the run.  Assumes "perl" subdirectory is PERLLIB (see code, sorry for the
hack).

=item nightly_cvs_dir : string ['perl/Bivio'],

The directory to checkout of cvs, which contains the source and the code.

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

=for html <a name="mock_sendmail"></a>

=head2 mock_sendmail(string from, string recipients)

=cut

sub mock_sendmail {
    my($self, $from, $recipients, $recursing) = @_;
    my($in) = $self->read_input;
    unless ($recursing) {
	my($pid) = fork;
	die("fork: $!")
	    unless defined($pid);
	return if $pid;
    }
    my($req) = $self->initialize_ui(1);
    unless ($from =~ s/^-f//) {
	$recipients = $from;
	$from = undef;
    }
    _trace($in) if $_TRACE;
    my($msg) = Bivio::IO::ClassLoader->simple_require('Bivio::Mail::Outgoing')
        ->new(
	    Bivio::IO::ClassLoader->simple_require('Bivio::Mail::Incoming')
	        ->new($in))
	->add_missing_headers($from, $req);
    foreach my $r (split(/,/, $recipients)) {
	(my $email = $r) =~ s/\+([^\@]+)//;
	my($extension) = $1 || '';
	$msg->set_recipients($r);
	my($res) = $self->piped_exec(
	    "b-sendmail-http 127.0.0.1 '$r' '"
	    . (Bivio::IO::ClassLoader
	        ->simple_require('Bivio::Test::Language::HTTP')
		->home_page_uri =~ m{http://([^/]+)})[0]
	    . $req->format_uri({
		task_id => 'MAIL_RECEIVE_DISPATCH',
		path_info => undef,
	    }) . "' /usr/bin/procmail -t -Y -a '$extension' -d '$email' 2>&1",
	    $msg->as_string,
	    1,
	);
	chomp($$res);
	_trace($r, ' => ', $res) if $_TRACE;
	next unless $$res;
	Bivio::IO::Alert->warn(
	    $r, ': failed with ', $$res, "\n", $msg->as_string);
	next if $recursing;
	$r = (Bivio::Mail::Address->parse(
	    $msg->unsafe_get_header('errors-to')
	    || $msg->unsafe_get_header('return-path')
	    || $from
	    || $self->unsafe_get('From')
	    ||next
	))[0];
	$self->put(
	    input => $msg->format_as_bounce($$res, undef, undef, $r),
	);
	$self->mock_sendmail('-f' . $req->format_email('mailer-daemon'), $r, 1);
    }
    CORE::exit(0)
	unless $recursing;
    return;
}

=for html <a name="nightly"></a>

=head2 nightly()

Creates test directory, calls cvs update to get latest test files.  Runs all
acceptance tests.  Output is to STDERR.

=cut

sub nightly {
    my($self) = @_;
    my($old_pwd) = Bivio::IO::File->pwd;
    _expunge($self);
    _make_nightly_dir($self);
    $ENV{PERLLIB} = Bivio::IO::File->pwd . '/perl'
	. ($ENV{PERLLIB} ? ":$ENV{PERLLIB}" : '');
    my($die) = Bivio::Die->catch(sub {
        # CVS checkout
        system('cvs -Q checkout ' . $_CFG->{nightly_cvs_dir});
        $self->print("Completed CVS checkout of test files\n");
        Bivio::IO::File->chdir($_CFG->{nightly_cvs_dir});
        $self->print($self->acceptance('.'));
        return;
    });
    # restore state before die is rethrown
    Bivio::IO::File->chdir($old_pwd);
    $die->throw if $die;
    return;
}

=for html <a name="task"></a>

=head2 task(any task, any query, any path_info) : array_ref

Executes the task, and returns the result. See
L<Bivio::Test::Request->execute_task|Bivio::Test::Request->execute_task>
for output details.

=cut

sub task {
    my($self, $task, $query, $path_info) = @_;
    Bivio::IO::ClassLoader->simple_require('Bivio::Test::Request')
	->get_instance;
    # Forces type check, and probably good thing anyway.
    $query = ref($query) ? {%$query}
	: $query ? Bivio::IO::ClassLoader->simple_require(
	    'Bivio::Agent::HTTP::Query')->parse($query)
	: undef;
    # Finishes realm, user, db init, and then executes task
    return $self->get_request->execute_task($task, {
	query => $query,
	path_info => $path_info,
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
    my($self, $tests) = _find_files(\@_, '(?:t|bunit)');
    return _run($self, $tests, sub {
        my($self, $test, $out) = @_;
	my($max, $ok) = (-1, 0);
	_piped_exec($self, _unit($test), $out, sub {
	    my($line) = @_;
	    if ($max >= 0) {
		$ok++ if $line =~ /^ok\s*(\d+)/;
	    }
	    elsif ($line =~ /^1\.\.(\d+)/) {
		$max = $1;
	    }
	});
	return $ok == $max;
    });
}

#=PRIVATE METHODS

# _expunge(self)
#
# Deletes old test directories. Keeps last two weeks.
#
sub _expunge {
    my($self) = @_;
    # this automatically loops through files in ascending order of timestamp
    # only works for this millenium
    my(@dirs) = glob("$_CFG->{nightly_output_dir}/2?????????????");
    while (@dirs > 14) {
	my($dir) = shift(@dirs);
        $self->print("Deleting old test directory: $dir\n");
	Bivio::IO::File->rm_rf($dir);
    }
    return;
}

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
    foreach my $arg (@$args) {
	my($is_file) = -f $arg;
	File::Find::find({
	    no_chdir => 1,
	    wanted => sub {
		return
		    unless $is_file
			|| $File::Find::name =~ /\.$pattern$/
			&& -r $File::Find::name;
		my(undef, $d, $f) = File::Spec->splitpath($File::Find::name);
		$d = File::Spec->rel2abs($d, $pwd);
		push(@{$tests->{$d} ||= []}, $f);
		return;
	    }},
	    $arg);
    }
    return ($self, $tests);
}

# _make_nightly_dir() : string
#
# Makes the directory in which nightly() executes and leaves testsuite
# log files.
#
sub _make_nightly_dir {
    my($self) = @_;
    my($dir) = $_CFG->{nightly_output_dir} . '/'
        . Bivio::Type::DateTime->local_now_as_file_name;
    Bivio::Die->die($dir, ': dir exists; move out of the way')
        if -d $dir;
    Bivio::IO::File->mkdir_p($dir);
    Bivio::IO::File->chdir($dir);
    $self->print("Created $dir\n");
    return $dir;
}

# _piped_exec(string command, string input, string_ref out, code_ref do)
#
# Call $do for each line.
#
sub _piped_exec {
    my($self, $command, $input, $out, $do) = @_;
    foreach my $line (split(/\n/,
	$$out = ${$self->piped_exec(
	    join(' ',
		$^X,
		'-w',
		$command,
		map({
		    # this regex is hairy to accommodate shell string escaping rules
		    s/'/'\\''/g;
		    "'$_'";
		} @{Bivio::IO::Config->command_line_args}),
		'2>&1',
	    ),
	    $input, 1)})
    ) {
	chomp($line);
	$do->($line);
    }
    return;
}

# _run(self, hash_ref tests, code_ref action)
#
# Runs the tests with action.
#
sub _run {
    my($self, $tests, $action) = @_;
    my($ok, $max) = (0, 0);
    my($failed) = [];
    my($one_dir) = keys(%$tests) == 1;
    foreach my $t (values(%$tests)) {
	$max += @$t;
    }
    $self->usage_error('no tests found') unless $max;
    foreach my $d (sort(keys(%$tests))) {
	$self->print("*** Entering: $d\n") unless $one_dir;
	Bivio::IO::File->chdir($d);
	foreach my $t (sort(@{$tests->{$d}})) {
	    $self->print(sprintf('%20s: ', $t));
	    my($res) = 'FAILED';
	    my($out);
	    if ($action->($self, $t, \$out)) {
		$res = 'PASSED';
		$ok++;
	    }
	    else {
		push(@$failed, File::Spec->catfile($d, $t));
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
    $self->print(
	(@$failed ? join("\n    ", 'Failed tests: ', @$failed) . "\n"
	    : ''),
	Bivio::Test->format_results($ok, $max));
    Bivio::Die->throw_quietly('DIE')
	unless $max == $ok;
    return;
}

# _unit(string test) : array
#
# If test ends in bunit, need to construct '.t'
#
sub _unit {
    my($test) = @_;
    return $test =~ /bunit$/ ? ('-', <<"EOF") : ($test, undef);
use strict;
use Bivio::Test::Unit;
Bivio::Test::Unit->run(q{$test});
EOF
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.

=head1 VERSION

$Id$

=cut

1;
