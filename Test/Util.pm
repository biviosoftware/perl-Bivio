# Copyright (c) 2001-2007 bivio Software, Inc.  All Rights reserved.
# $Id$
package Bivio::Test::Util;
use strict;
use Bivio::Base 'Bivio::ShellUtil';
use Bivio::Die;
use Bivio::IO::Config;
use Bivio::IO::File;
use Bivio::IO::Trace;
use Bivio::IO::Trace;
use Bivio::Test::Language;
use Bivio::Test;
use Bivio::Type::DateTime;
use File::Find ();
use File::Spec ();

# C<Bivio::Test::Util> runs acceptance and unit tests.  A unit test is defined
# using L<Bivio::Test|Bivio::Test>.  An acceptance test has its own language,
# which is a subclass of L<Bivio::Test::Language|Bivio::Test::Language>.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
Bivio::IO::Config->register({
    nightly_output_dir => '/tmp/test-run',
    nightly_cvs_dir => 'perl/Bivio',
});
my($_CFG);
my($_DT) = Bivio::Type->get_instance('DateTime');
my($_PERL_DIR) = '/perl';
my($_WN) = __PACKAGE__->use('Type.WikiName');
my($_F) = __PACKAGE__->use('UI.Facade');

sub USAGE {
    # Returns usage.
    return <<'EOF';
usage: b-test [options] command [args...]
commands:
    acceptance tests/dirs... - runs the tests (*.btest) under Bivio::Test::Language
    mock_sendmail -ffrom@email.com recipient1,recipient2,... -- bypasses MTA for acceptance tests
    nightly -- runs all acceptance tests with current tests from CVS
    remote_trace [named_filters] -- turn on tracing on a server
    task name query path_info facade -- executes task in context supplied returns output
    unit tests/dirs... -- runs the tests (*.t) and print cummulative results
EOF
}

sub acceptance {
    my($self, $tests) = _find_files(\@_, qr{\.btest$});
    # Executes I<test>(s) under L<Bivio::Test::Language|Bivio::Test::Language>.
    # I<test> may be a directory or file name.  If it is a directory, all tests
    # (C<*.btest>) files will be executed.  All tests must end in C<*.btest>.
    #
    # When only one test is run, shows the output of the test.
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

sub handle_config {
    my(undef, $cfg) = @_;
    # nightly_output_dir : string ['/tmp/test-run'],
    #
    # Root directory of the run.  A subdirectory will be created with the timestamp
    # of the run.  Assumes "perl" subdirectory is PERLLIB (see code, sorry for the
    # hack).
    #
    # nightly_cvs_dir : string ['perl/Bivio'],
    #
    # The directory to checkout of cvs, which contains the source and the code.
    $_CFG = $cfg;
    return;
}

sub mock_sendmail {
    my($self, $from, $recipients, $recursing) = @_;
    # You need to create the directory:
    #
    #     ~/btest-mail
    #
    # (default for Bivio::Test::Language::HTTP.mail_dir) and
    # have a ~/.procmailrc:
    #
    #     EXTENSION="$1"
    #     :0
    #     * EXTENSION ?? btest
    #     btest-mail/.
    my($in) = $self->read_input;
    unless ($recursing) {
	my($pid) = fork;
	die("fork: $!")
	    unless defined($pid);
	return if $pid;
    }
    my($req) = $self->initialize_fully;
    unless ($from =~ s/^-f//) {
	$recipients = $from;
	$from = undef;
    }
    _trace($in) if $_TRACE;
    my($msg) = b_use('Mail.Outgoing')
	->new(b_use('Mail.Incoming')->new($in))
	->add_missing_headers($req, $from);
    $msg->set_header('Return-Path', $from)
	if $from;
    foreach my $r (split(/,/, lc($recipients))) {
	(my $email = $r) =~ s/\+([^\@]+)//;
	my($extension) = $1 || '';
	$msg->set_recipients($r, $req);
	my($die);
	return Bivio::IO::Alert->warn($r, ': ', $die)
	    unless my $http = Bivio::Die->catch_quietly(
		sub {_uri_for_task($self, 'MAIL_RECEIVE_DISPATCH', $r)},
		\$die,
	    );
	$http =~ s{^http://}{};
	my($res) = $self->piped_exec(
	    "b-sendmail-http 127.0.0.1 '$r' '$http'"
		. " /usr/bin/procmail -t -Y -a '$extension' -d '$email' 2>&1",
	    $msg->as_string,
	    1,
	);
	chomp($$res);
	next
	    unless $$res;
	Bivio::IO::Alert->warn(
	    $msg->unsafe_get_header('from'),
	    ' -> ',
	    $r,
	    ': DELIVERY FAILED: ',
	    $res,
	);
	_trace($msg) if $_TRACE;
	next
	    if $recursing;
	$r = (Bivio::Mail::Address->parse(
	    $msg->unsafe_get_header('errors-to')
	    || $msg->unsafe_get_header('return-path')
	    || $from
	    || $msg->unsafe_get('From')
	    || next
	))[0];
	$self->put(
	    input => $msg->format_as_bounce($$res, undef, undef, $r, $req),
	);
	$self->mock_sendmail('-f' . $req->format_email('mailer-daemon'), $r, 1);
    }
    CORE::exit(0)
	unless $recursing;
    return;
}

sub nightly {
    # accepts first argument (name of test), but ignores
    my($self) = @_;
    # Creates test directory, calls cvs update to get latest test files.  Runs all
    # acceptance tests.  Output is to STDERR.
    my($old_pwd) = Bivio::IO::File->pwd;
    _expunge($self);
    _make_nightly_dir($self);
    $ENV{PERLLIB} = Bivio::IO::File->pwd . $_PERL_DIR
	. ($ENV{PERLLIB} ? ":$ENV{PERLLIB}" : '');
    my($die) = Bivio::Die->catch(sub {
        # CVS checkout
        (my $bop = $_CFG->{nightly_cvs_dir}) =~ s{\w+$}{Bivio};
	# Bivio/PetShop special case
#TODO: Move Bivio/PetShop to PetShop
	$bop =~ s{Bivio/Bivio}{Bivio};
        system("cvs -Q checkout '$_CFG->{nightly_cvs_dir}' '$bop'");
        $self->print("Completed CVS checkout of test files\n");
        Bivio::IO::File->chdir($_CFG->{nightly_cvs_dir});
	$self->print("cd ".Bivio::IO::File->pwd . "\n");
	$self->print("export PERLLIB=$ENV{PERLLIB}\n");
	$self->print("export BCONF=$ENV{BCONF}\n");
	$self->print("b-test acceptance .\n");
        $self->print($self->acceptance('.'));
        return;
    });
    # restore state before die is rethrown
    Bivio::IO::File->chdir($old_pwd);
    $die->throw if $die;
    return;
}

sub nightly_output_to_wiki {
    my($self, $msg) = @_;
    $self->initialize_fully;
    $msg ||= $self->read_input;
    my($q) = {path => $_WN->to_absolute('NightlyTestOutput')};
    my($rf) = $self->model('RealmFile');
    my($curr) = "\@h1 NightlyTestOutput\n";
    my($method) = 'create_with_content';
    if ($rf->unsafe_load($q)) {
	$curr = ${$rf->get_content};
	$method = 'update_with_content';
    }
    my($which, $date);
    my($result) = {};
    my($file) = {};
    foreach my $line (split(/\n/, ref($msg) ? $$msg : $msg)) {
	if ($line =~ m{^Created .*/([^/]+)/(\d+)$}is) {
	    ($which, $date) = ($1, $self->convert_literal(DateTime => $2));
	}
	elsif (!$which) {
	    next;
	}
        elsif ($line =~ m{^\s*(\S+): (PASSED|FAILED)$}is) {
	    my($t, $r) = ($1, $2);
	    $file->{$t} = 'MISSING'
		if ($result->{$t} = $r) =~ /FAILED/i;
	}
	elsif ($line =~ m{^\s*(.*/t/(.+))}is) {
	    $file->{$2} = $1;
	}
    }
    $date = $_DT->to_string($date);
    $curr = join(
	'@h3.',
	grep(
	    $_ !~ /^\w+ \w+ \Q$which\E /s,
	    split(/\@h3\./, $curr),
	),
    );
    my($class) = %$file ? 'FAILED' : 'passed';
    $curr =~ s{(?<=\n)}{
	join("\n",
	    "\@h3.$class $class $which $date",
	     !%$file ? () : (
		 '@dl.failed',
		 map(("\@dt $_", "\@dd $file->{$_}"),
		     sort(keys(%$file))),
		 '@/dl',
	     ),
	     '',
	 );
    }esx;
    $rf->$method($q, \$curr);
    return;
}

sub remote_trace {
    my($self, $named) = shift->name_args(['?PerlName'], \@_);
    $self->initialize_fully;
    my($ua) = $self->use('Ext.LWPUserAgent')->new;
    $ua->agent('b-test remote_trace');
    $ua->timeout(5);
    my($resp) = $ua->request(
	HTTP::Request->new(
	    'GET',
	    _uri_for_task($self, 'TEST_TRACE', undef, {path_info => $named}),
	),
    );
    Bivio::Die->die($resp)
        unless $resp->is_success;
    return;
}

sub task {
    my($self, $task, $query, $path_info, $facade) = @_;
    # Executes the task, and returns the result. See
    # L<Bivio::Test::Request->execute_task|Bivio::Test::Request->execute_task>
    # for output details.
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
    }, $facade || ());
}

sub unit {
    my($self, $tests) = _find_files(\@_, qr{\.(?:t|bunit)$});
    # Executes I<test>(s).  I<test> may be a directory or file name.  If it is a
    # directory, all tests (C<*.t>) files will be executed.  All tests must end in
    # C<*.t>.
    #
    # When only one test is run, shows the output of the test.
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

sub _expunge {
    my($self) = @_;
    # Deletes old test directories.
    # this automatically loops through files in ascending order of timestamp
    # only works for this millenium
    my(@dirs) = glob("$_CFG->{nightly_output_dir}/2?????????????");
    while (@dirs > 7) {
	my($dir) = shift(@dirs);
        $self->print("Deleting old test directory: $dir\n");
	Bivio::IO::File->rm_rf($dir);
    }
    return;
}

sub _find_files {
    my($args, $pattern) = @_;
    # Returns self, and hash of tests to run (dir, tests).
    my($self) = shift(@$args);
    $self->usage_error('must supply test files or directories')
	unless @$args;
    my($tests) = {};
    my($pwd) = Bivio::IO::File->pwd;
    foreach my $arg (@$args) {
	$arg = "t/$arg"
	    if !-e $arg && $arg =~ $pattern && -e "t/$arg";
	my($is_file) = -f $arg;
	File::Find::find({
	    no_chdir => 1,
	    wanted => sub {
		my(undef, $d, $f) = File::Spec->splitpath($File::Find::name);
		if (-d $File::Find::name) {
		    $File::Find::prune = 1
			if $f =~ /(?:^CVS|^old|-|\.old|^realm-data|.*\.tmp)$/;
		    return;
		}
		return
		    unless $is_file
			|| $File::Find::name =~ $pattern
			&& -r _;
		$d = File::Spec->rel2abs($d, $pwd);
		push(@{$tests->{$d} ||= []}, $f);
		return;
	    }},
	    $arg,
        );
    }
    return ($self, $tests);
}

sub _make_nightly_dir {
    my($self) = @_;
    # Makes the directory in which nightly() executes and leaves testsuite
    # log files.
    my($dir) = $_CFG->{nightly_output_dir} . '/'
        . Bivio::Type::DateTime->local_now_as_file_name;
    Bivio::Die->die($dir, ': dir exists; move out of the way')
        if -d $dir;
    Bivio::IO::File->mkdir_p($dir);
    Bivio::IO::File->chdir($dir);
    $self->print("Created $dir\n");
    return $dir;
}

sub _piped_exec {
    my($self, $command, $input, $out, $do) = @_;
    # Call $do for each line.
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

sub _run {
    my($self, $tests, $action) = @_;
    # Runs the tests with action.
    my($ok, $max) = (0, 0);
    my($failed) = [];
    my($one_dir) = keys(%$tests) == 1;
    foreach my $t (values(%$tests)) {
	$max += @$t;
    }
    $self->usage_error('no tests found') unless $max;
    foreach my $d (sort(keys(%$tests))) {
	$self->print("*** Entering: $d\n") unless $one_dir;
	Bivio::IO::File->do_in_dir($d => sub {
	    foreach my $t (sort(@{$tests->{$d}})) {
		my($res) = 'FAILED';
		my($out);
		if ($action->($self, $t, \$out)) {
		    $res = 'PASSED';
		    $ok++;
		}
		else {
		    push(@$failed, File::Spec->catfile($d, $t));
		}
		$self->print(sprintf('%20s: ', $t), $res, "\n");
		$out ||= '';
		$out =~ s/^/  /mg;
		if ($max == 1 || $self->get('verbose') && $res eq 'FAILED') {
		    $self->print("Output:\n", $out);
		}
	    }
	});
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

sub _unit {
    my($test) = @_;
    # If test ends in bunit, need to construct '.t'
    my($unit) = __PACKAGE__->use('TestUnit.Unit');
    return $test =~ /bunit$/ ? ('-', <<"EOF") : ($test, undef);
use strict;
use $unit;
${unit}->run(q{$test});
EOF
}

sub _uri_for_task {
    my($self, $task, $email_or_facade, $uri_args) = @_;
    my($facade) = $_F->setup_request(
	$email_or_facade ? ($email_or_facade =~ /@(.+)/)[0] || $email_or_facade
	    : $_F->get_default->get('uri'),
	$self->req,
    );
    my($http) = $self->use('TestLanguage.HTTP')->home_page_uri(
	$facade->get('uri'));
    Bivio::Die->die($http, ': TestLanguage.HTTP->home_page_uri missing http:')
        unless $http =~ m{http://[^/]+};
    return $http . $self->req->format_uri({
	realm => undef,
	task_id => $task,
	query => undef,
	path_info => undef,
	%{$uri_args || {}},
    });
}

1;
