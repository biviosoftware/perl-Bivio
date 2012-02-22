# Copyright (c) 2000-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::ShellUtil;
use strict;
use Bivio::Base 'Collection.Attributes';
use Bivio::IO::Trace;
use File::Spec ();
use POSIX ();
use Sys::Hostname ();

# C<Bivio::ShellUtil> is the base class for command line utilities.
# All shell utilities take a I<command> as their first argument
# followed by zero or more arguments.  I<command> must map to a
# method in the subclass.  The arguments are parsed by the method.
#
# L<setup|"setup"> creates a request from the standard
# voptions (I<user>, I<db>, and I<realm>).  It is called
# implicitly by L<get_request|"get_request">
#
# Options precede the command.  See L<OPTIONS|"OPTIONS">.  If the options
# contain references or are C<undef>, the value is used verbatim.  If
# the option value is a string, it will be parsed with the C<from_literal>
# of the option's type.
#
# For an example, see L<Bivio::Biz::Util::File|Bivio::Biz::Util::File>
# and L<Bivio::Biz::Util::Filtrum|Bivio::Biz::Util::Filtrum> (less complex).
#
# When implementing a subclass, try to avoid assumptions about $self.
# For example, don't assume $self is a reference and instead load things
# on the request.   As an example, in Bivio::Biz::Util::File, the volume
# is loaded on the request once it is parsed from $self if it is available.
#
# ShellUtils can't be subclassed and commands may not begin with "handle_".
# See _method_ok() below.
#
#
#
# argv : array_ref
#
# Unmodified argument vector.
#
# db : string [undef]
#
# Name of database to connect to.
#
# detach : boolean [0]
#
# Detach the process from standard output.  Output will receive all output.
#
# email : string [undef]
#
# Where to mail the output.  Uses I<result_subject>, I<result_type> and
# I<result_name>, if available.  If there is an exception, will email
# the die as a string instead of the text result.
#
# force : boolean [0]
#
# If true, L<are_you_sure|"are_you_sure"> will always return true.
#
# input : string [-]
#
# Reads the input file. If C<->, reads from stdin.  See
# L<read_input|"read_input">.
#
# input : string_ref
#
# The contents of the input file.  Value is returned verbatim from
# L<read_input|"read_input">.
#
# noexecute : boolean [1]
#
# Won't execute any "modifying" operations.  Will not call
# commit on termination.
#
# program : string
#
# Name of the program sans suffix and directory.
#
# output : string
#
# Name of the file to write the output to.
#
# realm : string [undef]
#
# The auth realm in which we are operating.
#
# req : Bivio::Agent::Request
#
# Request used for the call.  Initialized by L<setup|"setup">.
#
# result_name : string []
#
# File name of the result as set by the caller I<command> method.
#
# result_type : string []
#
# MIME type of the result as set by the caller I<command> method.
#
# user : string [undef or first_admin]
#
# The auth user used to execute I<command>.  If not set and
# I<realm> is set, will be implicitly set to the first_admin
# as defined by
# L<Bivio::Biz::Model::RealmAdminList|Bivio::Biz::Model::RealmAdminList>.
our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
# Map of class to Attributes which contains result of _parse_options()
my(%_DEFAULT_OPTIONS);
my($_A) = b_use('IO.Alert');
my($_C) = b_use('IO.Config');
my($_CA) = b_use('Collection.Attributes');
my($_CL) = b_use('IO.ClassLoader');
my($_DIE) = b_use('Bivio.Die');
my($_F) = b_use('IO.File');
my($_FP) = b_use('Type.FilePath');
my($_L) = b_use('IO.Log');
my($_M) = b_use('Biz.Model');
my($_TE) = b_use('Bivio.TypeError');
my($_MAP_NAME) = 'ShellUtil';
$_C->register(my $_CFG = {
    lock_directory => '/tmp',
    $_C->NAMED => {
	daemon_max_children => 1,
	daemon_sleep_after_start => 60,
	daemon_sleep_after_reap => 0,
	daemon_max_child_run_seconds => 0,
	daemon_max_child_term_seconds => 0,
	daemon_log_file => $_C->REQUIRED,
    },
});
my($_HANDLERS) = b_use('Biz.Registrar')->new;

sub OPTIONS {
    # Returns a mapping of options to bivio types and default values.
    #
    # Boolean is treated specially, but all other options are parsed
    # with L<Bivio::Type::from_literal|Bivio::Type/"from_literal">.
    # If an option is C<undef>, it was passed but not set properly.
    # If an option does not exist, it wasn't passed.
    #
    # You should always use L<getopt|"getopt">, because
    # it will return C<undef> in all cases, even if called statically.
    #
    # If the default value is C<undef>, the option will not be set.
    #
    # If the option begins with a unique first letter, the single
    # letter version is also supported.
    return {
#TODO: Add option -query which sets the query on the request
	db => ['Name', undef],
	detach => ['Boolean', 0],
	detach_log => ['Text', undef],
	email => ['Text', undef],
	force => ['Boolean', 0],
	input => ['Text', '-'],
	live => ['Boolean', 0],
	noexecute => ['Boolean', 0],
	realm => ['Line', undef],
	user => ['Line', undef],
        output => ['Line', undef],
	verbose => ['Boolean', 0],
    };
}

sub OPTIONS_USAGE {
    return <<'EOF';
options:
    -db - name of database connection
    -detach - calls detach process before executing command
    -detach_log - log file to use when detached
    -email - who to mail the results to (may be a comma separated list)
    -force - don't ask "are you sure?"
    -input - a file to read from ("-" is STDIN)
    -live - don't die on errors (used in weird circumstances)
    -noexecute - don't commit
    -output - a file to write the output to ("-" is STDOUT)
    -realm - realm_id or realm name
    -user - user_id or user name
EOF
}

sub USAGE {
    my($proto) = @_;
    # B<Subclasses may override this method to provide command details
    # in which case they should return the complete usage string, e.g.
    #
    #     usage: b-db-util [options] command [args...]
    #     commands:
    # 	   remote_sqlplus host db_login actions
    # 	   copy_logs_to_standby
    # 	   recover_standby
    # 	   sql2csv file.sql
    # 	   switch_logs_and_count_rows
    die('abstract method')
        if $proto->package_name eq __PACKAGE__;
    return join("\n",
        'usage: '._cleanup_command_name().' [options] command [args..]',
        'commands:',
        map("  $_", @{$proto->shell_commands}),
        '');
}

sub are_you_sure {
    my($self, $prompt) = @_;
    # Writes I<prompt> (default: "Are you sure?") to STDERR.  User must
    # answer "yes", on STDIN or the routine throws an exception.
    #
    # Does not prompt if:
    #
    #    * STDIN is not a tty (-t STDIN returns false)
    #    * self is not a reference (called statically)
    #    * -force option is true
    #
    # It is assumed STDERR is set up for autoflushing.

    # Not a tty?
    return unless -t STDIN;

    # Not an instance?
    return unless ref($self);

    # Force?
    return if $self->unsafe_get('force');

    $prompt ||= 'Are you sure?';
    $self->usage_error("Operation aborted")
	unless $self->readline_stdin($prompt." (yes or no) ") eq 'yes';

    # Yes answer
    return;
}

sub arg_list {
    my($proto, $args, $decls) = @_;
    $_A->warn_deprecated('use name_args');
    return $proto->name_args($decls, $args);
}

sub assert_have_user {
    my($self) = @_;
    $self->usage_error('must select a realm with -realm')
	unless $self->req('auth_user');
    return;
}

sub assert_not_general {
    my($self) = @_;
    $self->usage_error('must select a realm with -realm')
	if $self->req('auth_realm')->is_general;
    return;
}

sub assert_not_root {
    my($self) = @_;
    # Ensure the current command-line user is not root.
    $self->usage_error('this utility method may not be run as root')
        if $> == 0;
    return;
}

sub assert_test {
    return $_C->assert_test;
}

sub command_line {
    my($self) = @_;
    # Returns the command line that was used to execute this command.
    return ref($self)
	    ? join(' ', $self->unsafe_get('program') || '',
		    map {
			defined($_) ? $_ : '<undef>'
		    } @{$self->unsafe_get('argv') || []})
		    : 'N/A';
}

sub commit_or_rollback {
    my($self, $abort) = @_;
    my($method) = $self->unsafe_get('noexecute') || $abort
	? 'rollback' : 'commit';
    b_use('Agent.Task')->$method($self->req);
    return;
}

sub convert_literal {
    my($proto, $type) = (shift, shift);
    # Calls L<Bivio::Type::from_literal_or_die|Bivio::Type/"from_literal_or_die">
    # on I<value> by loading I<type> first.
    return $proto->use('Type', $type)->from_literal_or_die(@_);
}

sub detach_process {
    my($self) = @_;
    my($pid) = fork;
    die("fork: $!")
	unless defined($pid);
    return $pid
	if $pid;
    # Child
    my($log) = $_F->absolute_path(_detach_log($self));
    open(STDIN, '< /dev/null');
    open(STDOUT, "+> $log");
    open(STDERR, '>&STDOUT');
    select(STDERR);
    $| = 1;
    select(STDOUT);
    $| = 1;
    Bivio::IO::Alert->set_printer('FILE', $log);
    eval {
	require POSIX;
	POSIX::setsid();
    };
    return;
}

sub do_backticks {
    my($self, $command) = @_;
    my($res) = $self->piped_exec($command, undef, 1);
    return wantarray ? split(/(?<=\n)/, $$res) : $$res;
}

sub do_sh {
    my($self, @cmd) = shift->name_args(['LongText'], \@_);
    return join('', map(${$self->piped_exec($_)}, @cmd));
}

sub finish {
    my($self, $abort) = @_;
    # Calls L<commit_or_rollback|"commit_or_rollback"> and undoes setup.
    my($fields) = $self->[$_IDI];
    $self->commit_or_rollback($abort);
    $self->get_request->process_cleanup;
    b_use('SQL.Connection')->set_dbi_name($fields->{prior_db})
	if $fields->{prior_db};
    return;
}

sub get_request {
    my($self) = @_;
    return $self->unsafe_get('req') || $self->setup->get('req')
	if ref($self);
    my($req) = b_use('Agent.Request')->get_current;
    $_DIE->die('no request') unless $req;
    return $req;
}

sub group_args {
    my($proto, $group_size, $args) = @_;
    # Returns an array of I<group_size> tuples (array_refs).  Calls
    # L<usage_error|"usage_error"> if I<args> not modulo I<group_size>.
    #
    # I<args> is modified.
    $proto->usage_error("arguments must come in $group_size-tuples")
	unless @$args % $group_size == 0;
    my($res) = [];
    push(@$res, [splice(@$args, 0, $group_size)])
	while @$args;
    return $res;
}

sub handle_config {
    my(undef, $cfg) = @_;
    # daemon_log_file : string (named, required)
    #
    # Name of the log file for the daemon process.  Will be passed to
    # L<Bivio::IO::Log::file_name|Bivio::IO::Log/"file_name">, so may be relative.
    # The log file is openned at each write to avoid collisions and to make log
    # rotation easier.
    #
    # daemon_max_children : int [1] (named)
    #
    # Number of children for the worker.  This creates a single queue.
    #
    # daemon_max_child_run_seconds : int [0] (named)
    #
    # Maximum elapsed run-time in seconds for a single process.  If zero, no maximum.
    # If greater than zero, child will be killed with TERM after run-time exceeded.
    #
    # daemon_max_child_term_seconds : int [0] (named)
    #
    # Elapsed run-time after kill TERM, before kill KILL is sent to the child.
    #
    # daemon_sleep_after_reap : int [0] (named)
    #
    # If 0, then L<run_daemon|"run_daemon"> calls C<wait> and blocks forever
    # until any children exit.  This is normal behavior.
    #
    # If greater than 0, then childred are reaped by polling C<waitpid> with
    # C<POSIX::WNOHANG>.  After all children are reaped, the reaper (run_daemon)
    # sleeps for I<daemon_sleep_after_reap> before doing anything else.
    #
    # daemon_sleep_after_start : int [60] (named)
    #
    # Sleep after starts and before retries.
    #
    # lock_directory : string [/tmp]
    #
    # Where L<lock_action|"lock_action"> directories are created.  Must be absolute,
    # writable directory.
    $_DIE->die($cfg->{lock_directory}, ': not a writable directory')
	unless length($cfg->{lock_directory})
	    && -w $cfg->{lock_directory} && -d _;
    $_DIE->die($cfg->{lock_directory}, ': not absolute')
	unless File::Spec->file_name_is_absolute($cfg->{lock_directory});
    $_CFG = $cfg;
    return;
}

sub initialize_fully {
    # Same as initialize_ui(1).
    return shift->initialize_ui(1);
}

sub initialize_ui {
    my($self, $fully) = @_;
    # Initializes the UI and sets up the default facade.  This takes some time, so
    # classes should use this sparingly.  If I<fully> is true, initializes all
    # facades.  Otherwise, only initializes the default facade, and does not setup
    # tasks for execution.
    my($req) = $self->get_request;
    if ($req->can('setup_all_facades')) {
        b_use('Agent.Dispatcher')->initialize(!$fully);
        $req->setup_all_facades
            if $fully;
    }
    b_use('UI.Facade')->setup_request(undef, $req)
	unless $req->unsafe_get('UI.Facade');
    $req->put_durable(
	task => b_use('Agent.Task')->get_by_id($req->get('task_id')))
	if $req->unsafe_get('task_id');
    return $req;
}

sub is_execute {
    return shift->unsafe_get('noexecute') ? 0 : 1;
}

sub is_loadavg_ok {
    my($line) = $_F->read('/proc/loadavg');
    # Returns TRUE if the machine load is below a configurable
    # threshold.
    #
    # TODO: Make threshold configurable
    my(@load) = $$line =~ /^([\d\.]+)\s+([\d\.]+)\s+([\d\.]+)/;
    return $load[0] < 4 ? 1 : 0;
}

sub lock_action {
    my($proto, $op, $name, $no_warn) = @_;
    # Creates a file lock for I<name> in /tmp/.  If I<name> is undef,
    # uses C<caller> subroutine name.  The usage is:
    #
    #     sub my_action {
    # 	my($self, ...) = @_;
    # 	return Bivio::ShellUtil->lock_action(sub {
    # 	     do something;
    # 	});
    #     }
    #
    # Prints a warning of the lock couldn't be obtained.  If I<op> dies,
    # rethrows die after removing lock.
    #
    # The lock is a directory, and is owned by process.  If that process dies,
    # the lock is removed and re-acquired by this process.
    #
    # Returns the result of $op if lock was obtained and I<op> executed without
    # dying.  Returns () if lock could not be acquired.
    #
    #
    # B<DEPRECATED USAGE BELOW>
    #
    #
    # Creates a file lock for I<action> in I<lock_directory>.  If I<action> is undef,
    # uses C<caller> sub.  The usage is:
    #
    #     sub my_action {
    # 	my($self, ...) = @_;
    # 	return
    # 	    unless $self->lock_action;
    #     }
    #
    # This method forks a new process and returns true in the child process.
    # The parent waits for the child and returns.  There is no timeout, so
    # child must be designed to be robust.
    #
    # Catches TERM signal and resignals (to previous handler) bug first removes the
    # lock.
    return _deprecated_lock_action($op || (caller(1))[3])
	unless ref($op) eq 'CODE';
    my($lock_dir, $lock_pid) = _lock_files($name || (caller(1))[3]);
    foreach my $retry (1, 0) {
	last
	    if mkdir($lock_dir, 0700);
	unless ($retry) {
	    b_warn($lock_dir, ': unable to delete lock for dead process');
	    _lock_warning($lock_dir)
		unless $no_warn;
	    return;
	}
	my($pid, $host) = -r $lock_pid ? split(/\s+/, ${$_F->read($lock_pid)}) : ();
	if (($host && $host ne Sys::Hostname::hostname()) || _process_exists($pid)) {
	    _lock_warning($lock_dir)
		unless $no_warn;
	    return;
	}
	b_warn($pid, ": process doesn't exist, removing ", $lock_dir);
	# Don't test results, because there may be contention
	unlink($lock_pid);
	rmdir($lock_dir);
    }
    # Write host after pid to be backwards compatible with just pid format.
    $_F->write($lock_pid, $$ . ' ' . Sys::Hostname::hostname());
    my($prev) = $SIG{TERM};
    local($SIG{TERM}) = sub {
	unlink($lock_pid);
	rmdir($lock_dir);
	$SIG{TERM} = $prev;
	kill('TERM', $$);
	return;
    };
    my($die);
    my(@res) = $_DIE->catch($op, \$die);
    unlink($lock_pid);
    rmdir($lock_dir);
    $die->throw
	if $die;
    return $proto->return_scalar_or_array(@res);
}

sub lock_realm {
    my($self) = @_;
    # Locks the current realm.  Dies if general realm is auth_realm.
    # Handles re-locking existing realm.
    my($req) = $self->get_request;
    $_DIE->die("can't lock general realm")
	    if $req->get('auth_realm')->get('type')
		    == Bivio::Auth::RealmType->GENERAL();
    b_use('Model.Lock')->execute_unless_acquired($req);
    return;
}

sub main {
    my($proto, @argv) = @_;
    # Parses its arguments.  If I<argv[0]> contains is a valid public
    # method (definition: begins with a letter), will call it.
    # The rest of the arguments are passed verbatim
    # to this method.  If an error occurs, L<usage|"usage"> is called.
    #
    # Global options precede the command and are set on the instance.
    #
    # Returns the result as a string_ref if there is a result and wantarray is true.
    # This backward compatible feature was added to ease testing.
    local($|) = 1;

    my(@new_args);
    unless (ref($proto)) {
	push(@new_args, shift(@argv))
	    if $argv[0] && $argv[0] =~ /^[A-Z]/;
	push(@new_args, \@argv);
    }

    # Forces a setup, if called as $self
    my($self) = ref($proto) ? $proto->setup(_initialize($proto, \@argv))
	: $proto->new(@new_args);
    my($fields) = $self->[$_IDI];
    $fields->{in_main} = 1;

    if ($self->unsafe_get('db')) {
        # Setup DBI connection to access a probably non-default database
        $self->setup();
    }
    my($p) = $0 || '';
    $p =~ s!.*/!!;
    $p =~ s!\.\w+$!!;
    $self->put(program => $p);

    my($cmd, $res);
    my($die) = $_DIE->catch(sub {
	if (@argv && _method_ok($self, $argv[0])) {
	    $cmd = shift(@argv);
	}
	else {
	    $self->usage(@argv ? ($argv[0], ': unknown command')
	        : 'missing command');
	}
	return;
    });
    unless ($die) {
	my($pid);
	if ($self->unsafe_get('detach')) {
	    $_A->info('log=', _detach_log($self));
	    if ($pid = $self->detach_process) {
		$res = "$pid\n";
		$self->SUPER::delete(qw(output email req));
	    }
	}
	$die = $_DIE->catch(sub {
	    $res = $self->$cmd(@argv);
	}) unless $pid;
    }
    $fields->{in_main} = 0;

    # Don't finish if setup never called.
    $self->finish($die ? 1 : 0)
	if $self->unsafe_get('req');
    if ($die) {
	# Email error and re-throw
	$self->put(result_type => undef,
		result_subject => 'ERROR from: '.$self->command_line);
	_result_email($self, $cmd, $die->as_string);
	if ($self->unsafe_get('live')) {
	    $_A->warn($die);
	    return;
	}
	$die->throw();
	# DOES NOT RETURN
    }
    return $res
	if $res = $self->result($cmd, $res) and wantarray;
    return;
}

sub model {
    shift->get_request;
    return $_M->new_other_with_query(@_);
}

sub name_args {
    my($proto, $decls, $args) = @_;
    my($last_decl) = $decls->[$#$decls];
    my($res) = {};
    return (
	$proto,
	@{$proto->map_together(sub {
	    my($arg, $decl) = @_;
	    $decl ||= $last_decl;
	    $decl = [$decl]
		unless ref($decl);
	    my($name, $type, $default) = @$decl;
	    ($default, $type) = ($type, undef)
		if ref($type) eq 'CODE';
	    my($has_default) = $name =~ s/^\?// || defined($default)
		|| @$decl > 2;
	    $type ||= $name;
	    $type = "Type.$type"
		unless $type =~ /\W/;
	    $type = $proto->use($type);
	    my($v, $e) = $type->from_literal($arg);
	    return $res->{$name} = $v
		if defined($v);
	    unless ($e) {
		return $res->{$name} = ref($default) eq 'CODE'
		    ? $default->($proto, $res) : $default
		    if $has_default;
		$e = $_TE->NULL;
	    }
	    $proto->usage_error(
		$arg, ': invalid ', $name, ': ',
		$e->get_long_desc, '; see Type.', $type, "\n");
	    # DOES NOT RETURN
	}, $args, $decls)},
    );
    return;
}

sub new {
    my($proto, $class, $argv, $req) = @_;
    # Initializes a new instance with these command line arguments.

    if ($class && !ref($class)) {
	$proto = _other($proto, $class);
    }
    else {
	$argv = $class;
	$_DIE->die($proto, ': must not be called as ShellUtil->new')
	    if $proto eq __PACKAGE__;
    }
    return _initialize($proto->SUPER::new, $argv, $req);
}

sub new_other {
    my($self, $class) = @_;
    # Instantiates a new ShellUtil, whose class is I<class>.  Will load class
    # dynamically (must be fully qualified).  Passes standard options from I<self>
    # to I<other>
    # Calls I<put_request> on I<other> if there's a request on I<self>, i.e.
    # L<get_request|"get_request"> has been called.
    #
    # If I<self> is not an instance, no options are passed (defaults will
    # be used in I<other>).
    #
    # You can override options by calling I<put> on I<other> after this
    # call returns.
    # explicit die if not found
    # ClassLoader calls throw_quietly() which has no output
    my($c) = _other($self, $class);
    my($options) = [];
    if (ref($self)) {
	my($standard) = __PACKAGE__->OPTIONS();
	while (my($k, $v) = each(%$standard)) {
	    if ($v->[0] eq 'Boolean') {
		push(@$options, '-'.$k) if $self->unsafe_get($k);
	    }
	    else {
		# We don't pass undef options.
		my($actual) = $self->unsafe_get($k);
		push(@$options, '-'.$k, $actual)
			if defined($actual) != defined($v)
				|| defined($v) && $v ne $actual;
	    }
	}
    }
    my($other) = $c->new($options);
    $other->put_request($self->get_request)
	if $self->unsafe_get('req');
    $other->put(program => $self->unsafe_get('program'))
	if ref($self) && $self->has_keys('program');
    return $other;
}

sub piped_exec {
    my(undef, $command, $input, $ignore_exit_code) = @_;
    # Runs I<command> with I<input> (or empty input) and returns output.
    # I<input> may be C<undef>.
    #
    # Throws exception if it can't write the input. Throws exception if the
    # command returns a non-zero exit result unless ignore_exit_code is
    # specified.  The L<$_DIE|$_DIE> has an I<exit_code> attribute.
    my($in) = ref($input) ? $input : \$input;
    $$in = '' unless defined($$in);
    my($pid) = open(IN, "-|");
    defined($pid) || die("fork: $!");
#TODO: Use IO::File and $_F
    unless ($pid) {
	$_HANDLERS->call_fifo('handle_piped_exec_child');
	(ref($command) eq 'ARRAY'
	    ? open(OUT, '|-', @$command)
	    : open(OUT, "| exec $command")
	) || $_DIE->die($command, ": open failed: $!");
	print(OUT $$in);
	close(OUT);
	# If there is a signal, return 99.  Otherwise, return exit code.
	CORE::exit($? ? ($? >> 8) ? ($? >> 8) : 99 :  0);
    }
    my($res);
    if ($_TRACE) {
	_trace('START: ', $command);
	while (defined(my $line = <IN>)) {
	    $res .= $line;
	    _trace($line);
	}
	_trace('END: ', $command);
    }
    else {
	local($/) = undef;
	$res = <IN>;
    }
    # May be undef
    $res .= '';
    unless (close(IN)) {
	$_DIE->throw_die('DIE', {
	    message => 'command died with non-zero status',
	    entity => $command,
	    input => $in,
	    output => \$res,
	    exit_code => $?,
	}) unless $ignore_exit_code;
    }
    return \$res;
}

sub piped_exec_remote {
    my($self, $host, $command, $input, $ignore_exit_code) = @_;
    # Run I<command> remotely using C<ssh>.  Returns result.  Assumes remote shell
    # understands single quote escaping.
    if (defined($host)) {
	$command =~ s/'/'\''/g;
	$command = "ssh $host '($command) && echo OK$$'";
    }
    my($res) = $self->piped_exec($command, $input, $ignore_exit_code);
    $_DIE->throw_die('DIE', {
	message => 'remote command failed',
	host => $host,
	entity => $command,
	output => $res,
    }) unless $$res =~ s/OK$$\n// || $ignore_exit_code;
    return $res;
}

sub print {
    # Writes output to STDERR.  Returns result of print.
    # This method may be overriden.
    shift;
    return print(STDERR @_);
}

sub print_line {
    return shift->print(@_, "\n");
}

sub put {
    my($self) = shift;
    # If called statically, has no effect.  Otherwise, just calls
    # L<Bivio::Collection::Attributes::put|Bivio::Collection::Attributes/"put">.
    return unless ref($self);
    return $self->SUPER::put(@_);
}

sub put_request {
    my($self, $req) = @_;
    # Puts I<req> on I<self> and modifies other values appropriately.
    # Sets the current request to I<req>.
    return $self->put(req => $req);
}

sub read_input {
    my($self) = @_;
    # Returns the contents if I<input> argument.  If no argument, reads
    # from STDIN.  If I<input> is a ref, just return that.
    my($input) = $self->get('input');
    return ref($input) ? $input : $_F->read($input);
}

sub readline_stdin {
    my($self, $prompt) = @_;
    # Prints I<prompt>, and returns answer stripped of leading and trailing
    # whitespace.
    $self->print($prompt);
    my $answer = <STDIN>;
    chomp($answer);
    $answer =~ s/^\s+|\s+$//g;
    return $answer;
}

sub ref_to_string {
    return shift->use('IO.Ref')->to_string(@_);
}

sub register_handler {
    shift;
    $_HANDLERS->push_object(@_);
    return;
}

sub required_main {
    my($proto, $class, @args) = @_;
    my($pkgs) = $_CL->list_simple_packages_in_map($_MAP_NAME);
    $proto->usage_error(
	join("\n",
	     'first argument must be a class name.  Available classes:',
	     @$pkgs,
	)
	. "\n"
    ) unless $class;
    if ($proto->is_simple_package_name($class)) {
	my($c) = grep(/^\Q$class\E$/i, @$pkgs);
	$proto->usage_error($class, ": class not found in $_MAP_NAME map")
	    unless $c;
	$class = $c;
    }
    return ref($proto->new($_CL->map_require($_MAP_NAME => $class)))
	->main(@args);
}

sub result {
    my($self, $cmd, $res) = @_;
    # Processes I<res> by sending via I<email> and writing to I<output>
    # or printing to STDOUT.  Returns a reference to result or undef.
    $res = _result_ref($self, $res);
    return undef
	unless $res;
    print(STDOUT $$res, $$res =~ /\n$/s ? () : "\n")
	unless _result_email($self, $cmd, $res)
	+ _result_output($self, $cmd, $res);
    return $res;
}

sub run_daemon {
    my($self, $next_command, $cfg_name) = @_;
    # Starts a collection of processes using config defined by
    # I<cfg_name> (see L<handle_config|"handle_config">.
    $self->get_request;
    my($cfg) = $_C->get($cfg_name);
    # Makes log rotating simple: All processes share a log
    $_A->set_printer('FILE', $_L->file_name($cfg->{daemon_log_file}))
        if $cfg->{daemon_log_file};
    _check_cfg($cfg, $cfg_name);
    my($children) = {};
    my($ref) = b_use('IO.Ref');
    while (1) {
	my($max_duplicates) = $cfg->{daemon_max_children};
	while (keys(%$children) < $cfg->{daemon_max_children}) {
	    my($args) = $next_command->();
	    last unless $args;
	    _reap_daemon_children($children, 0, 0, $cfg);
	    if (grep(
		$ref->nested_equals($args, $_->{args}),
		values(%$children),
	    )) {
		_trace('already running: ', $args) if $_TRACE;
		# protects against infinite loop when daemon_max_children
		# is greater than the number of jobs.
		last if --$max_duplicates <= 0;
	    }
	    else {
		$children->{_start_daemon_child($self, $args, $cfg)} = {
		    args => $args,
		    $cfg->{daemon_max_child_run_seconds} > 0
		        ? (max_time =>
		            time + $cfg->{daemon_max_child_run_seconds})
		        : (),
		};
		sleep($cfg->{daemon_sleep_after_start});
	    }
	}
	return unless %$children;
	_reap_daemon_children(
	    $children,
	    $cfg->{daemon_sleep_after_reap} > 0
	        ? (0, $cfg->{daemon_sleep_after_reap})
	        : (wait, 0),
	    $cfg,
	);
    }
    return;
}

sub send_mail {
    my($self, $email, $subject, $body) = @_;
    my($msg) = b_use('Mail.Outgoing')->new;
    my($req) = $self->get_request;
    $msg->set_recipients($email, $req);
    $msg->set_header('Subject', $subject);
    $msg->set_header('To', $email);
    $msg->set_from_with_user($req);
    if (ref($body) eq 'CODE') {
	$body->($msg);
    }
    elsif ($_CL->was_required('Model.RealmFile')
        && b_use('Model.RealmFile')->is_blesser_of($body),
    ) {
	$msg->set_content_type('multipart/mixed');
	$msg->attach({
	    content => $body->get_content,
	    content_type => $body->get_content_type,
	    filename => $_FP->get_tail($body->get('path')),
	});
    }
    elsif (ref($body) eq 'SCALAR') {
	$msg->set_body($body);
    }
    else {
	b_die($body, ': invalid message body type');
    }
    $msg->send($req)
        unless $self->unsafe_get('noexecute');
    return;
}

sub set_realm_and_user {
    my($self, $realm, $user) = @_;
    $realm = b_use('Auth.Realm')->get_general()
	unless defined($realm);
    my($req) = $self->get_request;
    $req->set_realm($realm);

    if (defined($user)) {
	$req->set_user($user);
	return $self;
    }
    $self->set_user_to_any
	unless $req->get('auth_realm')->is_general;
    return $self;
}

sub set_user_to_any {
    return _any_user(unsafe_get_any_online_admin => @_);
}

sub set_user_to_any_online_admin {
    return _any_user(get_any_online_admin => @_);
}

sub setup {
    my($self) = @_;
    # Configures the environment for request.  Does nothing if already setup.
    my($fields) = $self->[$_IDI];
    $fields->{in_main} ? _setup_for_main($self) : _setup_for_call($self);
    return $self;
}

sub shell_commands {
    my($proto) = @_;
    no strict qw(refs);
    my($cmd_usage) = sub {
        my($cmd) = @_;
        my($fn) = $proto->can("${cmd}_USAGE");
        $cmd .= ' '.$fn->()
            if ref($fn) eq 'CODE';
        return $cmd;
    };
    return [
        map($cmd_usage->($_),
        sort(
        grep(!/(^b_|^_|^[A-Z0-9_]+$|_USAGE$)/
             && *{$proto->package_name.'::'.$_}{CODE},
        keys(%{*{$proto->package_name.'::'}}))))];
}


sub unauth_model {
    shift->get_request;
    return $_M->new_other_with_query(@_);
}

sub unauth_realm_id {
    return shift->model('RealmOwner')->unauth_load_and_get_id(@_);
}

sub unsafe_get {
    my($self) = shift;
    return $self->SUPER::unsafe_get(@_) if ref($self);
    $_DEFAULT_OPTIONS{$self} = $_CA->new(_parse_options($self, []))
	unless $_DEFAULT_OPTIONS{$self};
    return $_DEFAULT_OPTIONS{$self}->unsafe_get(@_);
}

sub usage {
    my($proto) = shift;
    $proto->usage_error(@_, "\n", $proto->USAGE, $proto->OPTIONS_USAGE);
    # DOES NOT RETURN
}

sub usage_error {
    my(undef, @args) = @_;
    push(@args, "\n")
	unless ($args[$#args] || '') =~ /\n$/s;
    $_A->print_literally('ERROR: ', @args);
    $_DIE->throw_quietly('DIE');
    # DOES NOT RETURN
}

sub write_file {
    my(undef, $file_name, $contents) = @_;
    # DEPRECATED: See L<$_F::write|$_F/"write">
    $_A->warn_deprecated('use $_F->write');
    return $_F->write($file_name, $contents);
}

sub _any_user {
    my($method, $self) = @_;
    $self->req->set_user(
	$self->model('RealmUser')->$method()
            || $self->model('User')
		->do_iterate(sub {0}, unauth_iterate_start => 'user_id asc')
		->unsafe_get('user_id')
	    || $self->unauth_model(RealmOwner => {name => 'user'})
		->unsafe_get('realm_id'),
    );
    $self->put(user => my $u = $self->ureq(qw(auth_user name)));
    return $u;
}

sub _check_cfg {
    my($cfg, $cfg_name) = @_;
    # Asserts config is valid
    while (my($k, $v) = each(%$cfg)) {
	next unless $k =~ /_(?:sleep|max|child)_/;
	next if $v =~ /^\d+$/ && $v >= 0;
	my($dv) = $_CFG->{$_C->NAMED}->{$k};
	$_A->warn($v, ': bad value for ',
	    ($cfg_name ? "$cfg_name." : ''), $k,
	    '; using ', $dv);
	$cfg->{$k} = $dv;
    }
    if ($cfg->{daemon_max_child_run_seconds} > 0
	&& $cfg->{daemon_sleep_after_reap} <= 0) {
	$_A->warn('daemon_sleep_after_reap must be non-zero',
	    ' when daemon_max_child_run_seconds is non-zero; using 1 second');
	$cfg->{daemon_sleep_after_reap} = 1;
    }
    return;
}

sub _cleanup_command_name {
    $0 =~ qr{([-\w]+)$}; #exclude path to $0 in output
    return _special_handling_to_append_argv0_for_bivio($1);
}

sub _compile_options {
    my($self) = @_;
    # Compiles the options string.  Returns a map of options to declarations
    # as a hash_ref and an array_ref of the declarations.  A declaration
    # is an array_ref (name, type, default).
    my($options) = $self->OPTIONS;
    return ({}, []) unless $options && keys(%$options);

    my($map) = {};
    my($opts) = [];
    foreach my $k (keys(%$options)) {
	die("$k: options must be valid perl idents with at least on character")
	    unless $k =~ /^[a-z]\w+$/i;
	my($first) = substr($k, 0, 1);
	my($type, $default) = @{$options->{$k}};
	my($opt) = [$k, b_use(Type => $type)];
	$opt->[2] = _parse_option_value($self, $opt, $default);
	$map->{$first} = exists($map->{$first}) ? 0 : $opt;
	$map->{$k} = $opt;
	push(@$opts, $opt);
    }
    while (my($k, $v) = each(%$map)) {
	delete($map->{$k})
	    unless $v;
    }
    return ($map, $opts);
}

sub _deprecated_lock_action {
    my($action) = @_;
    # Implements deprecated form of lock_action.
    my($dir) = _lock_files($action);
    unless (mkdir($dir, 0700)) {
	_lock_warning($dir);
	return 0;
    }
    my($pid) = fork;
    defined($pid) || die("fork: $!");
    return 1 unless $pid;
    # Parent process waits for child to finish
    my($res) = waitpid($pid, 0) == -1 ? undef : $?;
    # Don't need an error check; rather have $res always returned
    rmdir($dir);
    die("waitpid failed: $!\nsomething seriously wrong")
	unless defined($res);
    die("$action failed\n") if $res;

    # Tell caller to return, not exit()
    return 0;
}

sub _detach_log {
    my($self) = @_;
    return $self->get_if_exists_else_put(detach_log => sub {
        return $_F->absolute_path(
	    b_use('Type.DateTime')->local_now_as_file_name
		. '-'
		. $self->get('program')
		. '.log',
	);
    });
}

sub _initialize {
    my($self, $argv, $req) = @_;
    # Initializes the instance with the appropriate params.
    $argv ||= [];
    my($orig_argv) = [@$argv];
    $self->[$_IDI] ||= {};
    return $self->put(
	%{_parse_options($self, $argv)},
	argv => $orig_argv,
    )->put_request($req);
}

sub _lock_files {
    my($name) = @_;
    # Returns the $name converted to (lock_dir, lock_pid)
    # Strip illegal chars
    $name =~ s{@{[b_use('Type.FileName')->ILLEGAL_CHAR_REGEXP]}+}{}g;
    my($d) = File::Spec->catdir($_CFG->{lock_directory}, "$name.lockdir");
    return ($d, File::Spec->catfile($d, 'pid'));
}

sub _lock_warning {
    my($lock_dir) = @_;
    b_warn(
	$lock_dir,
	': not acquired; lock age=',
	time - (stat($lock_dir))[9],
	's',
    );
    return;
}

sub _method_ok {
    my($self, $method) = @_;
    # Returns true if the public method exists in subclass or if the
    # method is 'usage'.
    return 0 unless $method =~ /^([a-z]\w*)$/i;
    return 0 if $method =~ /^handle_/;
    return 1 if $method eq 'usage';
    foreach my $c (ref($self), @{$self->inheritance_ancestors}) {
	last if $c eq __PACKAGE__;
#TODO: Need to deprecate calls which __PACKAGE__->can($method) && $c->can.
	return 1 if $c->can($method);
    }
    return 0;
}

sub _monitor_daemon_children {
    my($children, $cfg) = @_;
    # Monitor children max_time if daemon_max_child_run_seconds is greater than
    # zero.
    return unless $cfg->{daemon_max_child_run_seconds} > 0;
    my($t) = time;
    while (my($pid, $child) = each(%$children)) {
	next if $t < $child->{max_time};
	my($sig) = $child->{kill_term}++ ? 'KILL' : 'TERM';
	kill($sig, $pid);
	$_A->info("Sent SIG$sig: pid=", $pid, ' args=',
	    join(' ', splice(@{$child->{args}}, 2)));
	$child->{max_time} = $t + $cfg->{daemon_max_child_term_seconds}
    }
    return;
}

sub _other {
    my($self, $class) = @_;
    my($die);
    $class = "$_MAP_NAME.$class"
	if $self->is_simple_package_name($class);
    return $_DIE->catch_quietly(
	sub {b_use($class)},
	\$die,
    ) || $_DIE->die($class, ": $_ not found or syntax error: ", $die);
}

sub _parse_option_value {
    my($self, $opt, $value) = @_;
    # Returns the options that were set.
    return $value
	if ref($value) || !defined($value);
    my($v, $e) = $opt->[1]->from_literal($value);
    $self->usage("-$opt->[0] '$value': ", $e->get_long_desc)
	if $e;
    return $v;
}

sub _parse_options {
    my($self, $argv) = @_;
    # Returns the options that were set.
    my($res) = {};
    my($map, $opts) = _compile_options($self);
    return {} unless %$map;

    # Parse the options
    while (@$argv && $argv->[0] =~ /^-/) {
	my($k) = shift(@$argv);
	$k =~ s/^-//;
	my($opt) = $map->{$k};
	$self->usage("-$k: unknown option") unless $opt;
	if ($opt->[1] eq 'Bivio::Type::Boolean') {
	    $res->{$opt->[0]} = 1;
	    next;
	}
	$self->usage("-$k: missing an argument")
	    unless @$argv;
	$res->{$opt->[0]} = _parse_option_value($self, $opt, shift(@$argv));
    }

    # Set the (defined) defaults
    foreach my $opt (@$opts) {
	next if exists($res->{$opt->[0]});
	next unless defined($opt->[2]);
	$res->{$opt->[0]} = $opt->[2];
    }
    $res->{output} = $_F->absolute_path($res->{output})
	if defined($res->{output}) && $res->{output} ne '-';
    _trace($res) if $_TRACE;
    return $res;
}

sub _parse_realm {
    my($self, $attr) = @_;
    # Returns the id or undef for realm.
    return undef
	unless my $realm = $self->unsafe_get($attr);
    my($ro) = $self->model('RealmOwner');
    $self->usage_error($realm, ': no such ', $attr)
	unless $ro->unauth_load_by_email_id_or_name($realm);
    return $ro;
}

sub _process_exists {
    my($pid) = @_;
    return 0
	unless $pid;
    # Returns true if $pid exists
    $! = undef;
    return kill(0, $pid) || $! != POSIX::ESRCH() ? 1 : 0;
}

sub _reap_daemon_children {
    my($children, $stopped, $sleep, $cfg) = @_;
    # Reap children without blocking
    while (1) {
	if ($stopped > 0) {
	    if (my $child = delete($children->{$stopped})) {
		$_A->info('Stopped: pid=', $stopped, ' args=',
		    join(' ', splice(@{$child->{args}}, 2)));
	    }
	    else {
		$_A->warn($stopped, ': unknown pid');
	    }
	}
	$stopped = waitpid(-1, POSIX::WNOHANG());
	last unless $stopped > 0;
    }
    _monitor_daemon_children($children, $cfg);
    sleep($sleep)
	if $sleep;
    return;
}

sub _result_email {
    my($self, $cmd, $res) = @_;
    # Emails the result if there is an email option (returns true in that case).
    my($email) = $self->unsafe_get('email');
    return 0 unless $email;

    my($name, $type, $subject) = $self->unsafe_get(
	    qw(result_name result_type result_subject));
    $self->send_mail(
	$email,
	$subject || $name || 'Output from: '.$self->command_line(),
	sub {
	    my($msg) = @_;
	    if ($type) {
		$msg->set_content_type('multipart/mixed');
		# Can't use -B and couldn't get IO::Scalar to work.
		# Just assume is binary
		$msg->attach($res, $type, $name || $cmd, 1);
	    }
	    else {
		$msg->set_body($res);
	    }
	    return;
	}
    );
    return 1;
}

sub _result_output {
    my($self, $cmd, $res) = @_;
    # Returns true if there is an output option and it is written to a file.
    my($output) = $self->unsafe_get('output');
    return 0 unless $output;

    $_F->write($output, $res);
    return 1;
}

sub _result_ref {
    my($self, $res) = @_;
    # Returns a scalar reference to the result or undef if no result to print.
    # Will print any structure.
    return undef
	unless defined($res);
    my($ref) = \$res;
    if (ref($res)) {
	return $self->ref_to_string($res)
	    unless ref($res) eq 'SCALAR';
	$ref = $res;
    }
    return defined($$ref) && length($$ref) ? $ref : undef;
}

sub _setup_for_call {
    my($self) = @_;
    # Called from within a program.  Request must be setup already or dies.
    # Doesn't allow certain attributes.  Sets user and realm only if passed
    # explicitly.
    my($req) = b_use('Agent.Request')->get_current;
    $_DIE->die(ref($self), ": called without first creating a request")
	unless $req;
    $self->put_request($req);
    foreach my $x (qw(realm user)) {
	next unless my $v =_parse_realm($self, $x);
	my($m) = "set_$x";
	$req->$m($v);
    }
    foreach my $attr (qw(db)) {
	$_DIE->die($attr, ': cannot pass to ', ref($self), ' call')
	    if $self->unsafe_get($attr);
    }
    return;
}

sub _setup_for_main {
    my($self) = @_;
    # Called from "main".  Always creates a Job::Request.  Initializes db.
    # Sets realm/user.
    my($fields) = $self->[$_IDI];
    my($db, $user, $realm) = $self->unsafe_get(qw(db user realm));
    my($p) = b_use('SQL.Connection')->set_dbi_name($db);
    $fields->{prior_db} = $p unless $fields->{prior_db};
    $self->put_request(
	b_use('Test.Request')->get_instance->put_durable(is_secure => 1),
    ) unless $self->unsafe_get('req');
    $self->set_realm_and_user(map(_parse_realm($self, $_), qw(realm user)));
    return;
}

sub _special_handling_to_append_argv0_for_bivio {
    my($cmd) = @_;
    return $cmd eq 'bivio' ? "$1 $ARGV[0]" : $cmd;
}

sub _start_daemon_child {
    my($self, $args, $cfg) = @_;
    # Starts child process, appending to log.  Returns pid.
    # Force a reconnect for both child and parent; avoids errors in
    # logs for parent.
    b_use('SQL.Connection')->disconnect;
    $_A->reset_warn_counter;
 RETRY: {
	my($child) = fork;
	unless (defined($child)) {
	    b_warn($args,
		" fork: $!; sleeping before retry");
	    sleep($cfg->{daemon_sleep_after_start});
	    redo RETRY;
	}
	if ($child) {
	    _trace('started: ', $child, ' ', $args) if $_TRACE;
	    return $child;
	}
	$self->get_request->clear_current;
	$0 = join(' ', @$args);
	$_A->info('Starting: pid=', $$, ' args=',
	    join(' ', @$args[2 .. $#$args]));
	# Reset so we can send signals in _monitor_daemon_children()
	local($SIG{TERM}) = 'DEFAULT';
        $args->[0]->main(@$args[1 .. $#$args]);
	CORE::exit(0);
    }
}

1;
