# Copyright (c) 2000-2006 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::ShellUtil;
use strict;
$Bivio::ShellUtil::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::ShellUtil::VERSION;

=head1 NAME

Bivio::ShellUtil - base class for command line utilities

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::ShellUtil;
    __PACKAGE__->main(@ARGV);

=cut

=head1 EXTENDS

L<Bivio::Collection::Attributes>

=cut

use Bivio::Collection::Attributes;
@Bivio::ShellUtil::ISA = ('Bivio::Collection::Attributes');

=head1 DESCRIPTION

C<Bivio::ShellUtil> is the base class for command line utilities.
All shell utilities take a I<command> as their first argument
followed by zero or more arguments.  I<command> must map to a
method in the subclass.  The arguments are parsed by the method.

L<setup|"setup"> creates a request from the standard
voptions (I<user>, I<db>, and I<realm>).  It is called
implicitly by L<get_request|"get_request">

Options precede the command.  See L<OPTIONS|"OPTIONS">.  If the options
contain references or are C<undef>, the value is used verbatim.  If
the option value is a string, it will be parsed with the C<from_literal>
of the option's type.

For an example, see L<Bivio::Biz::Util::File|Bivio::Biz::Util::File>
and L<Bivio::Biz::Util::Filtrum|Bivio::Biz::Util::Filtrum> (less complex).

When implementing a subclass, try to avoid assumptions about $self.
For example, don't assume $self is a reference and instead load things
on the request.   As an example, in Bivio::Biz::Util::File, the volume
is loaded on the request once it is parsed from $self if it is available.

ShellUtils can't be subclassed and commands may not begin with "handle_".
See _method_ok() below.

=head1 ATTRIBUTES

=over 4

=item argv : array_ref

Unmodified argument vector.

=item db : string [undef]

Name of database to connect to.

=item detach : boolean [0]

Detach the process from standard output.  Output will receive all output.

=item email : string [undef]

Where to mail the output.  Uses I<result_subject>, I<result_type> and
I<result_name>, if available.  If there is an exception, will email
the die as a string instead of the text result.

=item force : boolean [0]

If true, L<are_you_sure|"are_you_sure"> will always return true.

=item input : string [-]

Reads the input file. If C<->, reads from stdin.  See
L<read_input|"read_input">.

=item input : string_ref

The contents of the input file.  Value is returned verbatim from
L<read_input|"read_input">.

=item noexecute : boolean [1]

Won't execute any "modifying" operations.  Will not call
commit on termination.

=item program : string

Name of the program sans suffix and directory.

=item output : string

Name of the file to write the output to.

=item realm : string [undef]

The auth realm in which we are operating.

=item req : Bivio::Agent::Request

Request used for the call.  Initialized by L<setup|"setup">.

=item result_name : string []

File name of the result as set by the caller I<command> method.

=item result_type : string []

MIME type of the result as set by the caller I<command> method.

=item user : string [undef or first_admin]

The auth user used to execute I<command>.  If not set and
I<realm> is set, will be implicitly set to the first_admin
as defined by
L<Bivio::Biz::Model::RealmAdminList|Bivio::Biz::Model::RealmAdminList>.

=back

=cut

=head1 CONSTANTS

=cut

=for html <a name="OPTIONS_USAGE"></a>

=head2 OPTIONS_USAGE : string

Called by L<usage|"usage"> and returns the string:

  options:
      -db - name of database connection
      -detach - calls detach process before executing command
      -email - who to mail the results to (may be a comma separated list)
      -force - don't ask "are you sure?"
      -input - a file to read from ("-" is STDIN)
      -live - don't die on errors (used in weird circumstances)
      -noexecute - don't commit
      -output - a file to write the output to ("-" is STDOUT)
      -realm - realm_id or realm name
      -user - user_id or user name

=cut

sub OPTIONS_USAGE {
    return <<'EOF';
options:
    -db - name of database connection
    -detach - calls detach process before executing command
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

=for html <a name="OPTIONS"></a>

=head2 OPTIONS : hash_ref

Returns a mapping of options to bivio types and default values.
The default values are:

    {
	db => ['Name', undef],
	detach => ['Boolean', 0],
	email => ['Text', undef],
	force => ['Boolean', 0],
	input => ['Line', '-'],
	live => ['Boolean', 0],
	noexecute => ['Boolean', 0],
	realm => ['Line', undef],
	user => ['Line', undef],
        output => ['Line', undef],
    }

Boolean is treated specially, but all other options are parsed
with L<Bivio::Type::from_literal|Bivio::Type/"from_literal">.
If an option is C<undef>, it was passed but not set properly.
If an option does not exist, it wasn't passed.

You should always use L<getopt|"getopt">, because
it will return C<undef> in all cases, even if called statically.

If the default value is C<undef>, the option will not be set.

If the option begins with a unique first letter, the single
letter version is also supported.

=cut

sub OPTIONS {
    return {
	db => ['Name', undef],
	detach => ['Boolean', 0],
	email => ['Text', undef],
	force => ['Boolean', 0],
	input => ['Line', '-'],
	live => ['Boolean', 0],
	noexecute => ['Boolean', 0],
	realm => ['Line', undef],
	user => ['Line', undef],
        output => ['Line', undef],
    };
}

=for html <a name="USAGE"></a>

=head2 abstract USAGE : string

B<Subclasses must override this method.>

Returns the usage string, e.g.

    usage: b-db-util [options] command [args...]
    commands:
	   remote_sqlplus host db_login actions
	   copy_logs_to_standby
	   recover_standby
	   sql2csv file.sql
	   switch_logs_and_count_rows

=cut

sub USAGE {
    die('abstract method');
}

#=IMPORTS
use Bivio::IO::Config;
use Bivio::Die;
use Bivio::IO::File;
use Bivio::IO::Ref;
use Bivio::IO::Trace;
use Bivio::Type;
use Bivio::Type::DateTime;
use Bivio::TypeError;
use File::Spec ();
use POSIX ();
use Sys::Hostname ();

#=VARIABLES
my($_IDI) = __PACKAGE__->instance_data_index;
# Map of class to Attributes which contains result of _parse_options()
my(%_DEFAULT_OPTIONS);
Bivio::IO::Config->register(my $_CFG = {
    lock_directory => '/tmp',
    Bivio::IO::Config->NAMED => {
	daemon_max_children => 1,
	daemon_sleep_after_start => 60,
	daemon_sleep_after_reap => 0,
	daemon_max_child_run_seconds => 0,
	daemon_max_child_term_seconds => 0,
	daemon_log_file => Bivio::IO::Config->REQUIRED,
    },
});

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::ShellUtil

=head2 static new(array_ref argv) : Bivio::ShellUtil

=head2 static new(string class, array_ref argv) : Bivio::ShellUtil

Initializes a new instance with these command line arguments.

=cut

sub new {
    my($proto, $class, $argv) = @_;

    if ($class && !ref($class)) {
        # explicit die if not found
        # ClassLoader calls throw_quietly() which has no output
        my($c) = Bivio::Die->eval(sub {
            Bivio::IO::ClassLoader->map_require('ShellUtil', $class);
        });
        Bivio::Die->die('other ShellUtil not found or syntax error: ', $class)
            unless $c;
	$proto = $c;
    }
    else {
	$argv = $class;
	Bivio::Die->die('new() must be called on a ShellUtil subclass')
	    if $proto eq __PACKAGE__;
    }

    return _initialize($proto->SUPER::new, $argv);
}

=for html <a name="new_other"></a>

=head2 new_other(string class) : Bivio::ShellUtil

Instantiates a new ShellUtil, whose class is I<class>.  Will load class
dynamically (must be fully qualified).  Passes standard options from I<self>
to I<other>
Calls I<put_request> on I<other> if there's a request on I<self>, i.e.
L<get_request|"get_request"> has been called.

If I<self> is not an instance, no options are passed (defaults will
be used in I<other>).

You can override options by calling I<put> on I<other> after this
call returns.

=cut

sub new_other {
    my($self, $class) = @_;
    # explicit die if not found
    # ClassLoader calls throw_quietly() which has no output
    my($c) = Bivio::Die->eval(sub {
        Bivio::IO::ClassLoader->map_require('ShellUtil', $class);
    });
    Bivio::Die->die('other ShellUtil not found or syntax error: ', $class)
        unless $c;
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
    $other->put_request($self->get_request);
    $other->put(program => $self->unsafe_get('program'))
	if ref($self) && $self->has_keys('program');
    return $other;
}

=head1 METHODS

=cut

=for html <a name="are_you_sure"></a>

=head2 are_you_sure()

=head2 are_you_sure(string prompt)

Writes I<prompt> (default: "Are you sure?") to STDERR.  User must
answer "yes", on STDIN or the routine throws an exception.

Does not prompt if:

   * STDIN is not a tty (-t STDIN returns false)
   * self is not a reference (called statically)
   * -force option is true

It is assumed STDERR is set up for autoflushing.

=cut

sub are_you_sure {
    my($self, $prompt) = @_;

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

=for html <a name="assert_not_general"></a>

=head2 assert_not_general()

Ensure auth_realm is not general.

=cut

sub assert_not_general {
    my($self) = @_;
    $self->usage_error('must select a realm with -realm')
	if $self->get_request->get('auth_realm')->is_general;
    return;
}

=for html <a name="assert_not_root"></a>

=head2 assert_not_root()

Ensure the current command-line user is not root.

=cut

sub assert_not_root {
    my($self) = @_;
    $self->usage_error('this utility method may not be run as root')
        if $> == 0;
    return;
}

=for html <a name="command_line"></a>

=head2 command_line() : string

Returns the command line that was used to execute this command.

=cut

sub command_line {
    my($self) = @_;
    return ref($self)
	    ? join(' ', $self->unsafe_get('program') || '',
		    map {
			defined($_) ? $_ : '<undef>'
		    } @{$self->unsafe_get('argv') || []})
		    : 'N/A';
}

=for html <a name="commit_or_rollback"></a>

=head2 commit_or_rollback(boolean abort)

Commits if !I<abort> and !I<noexecute>.

=cut

sub commit_or_rollback {
    my($self, $abort) = @_;
    Bivio::IO::ClassLoader->simple_require('Bivio::Agent::Task');
    $self->unsafe_get('noexecute') || $abort
	    ? Bivio::Agent::Task->rollback($self->get_request)
		    : Bivio::Agent::Task->commit($self->get_request);
    return;
}

=for html <a name="convert_literal"></a>

=head2 static convert_literal(string type, any value) : any

Calls L<Bivio::Type::from_literal_or_die|Bivio::Type/"from_literal_or_die">
on I<value> by loading I<type> first.

=cut

sub convert_literal {
    my($proto, $type) = (shift, shift);
    return Bivio::Type->get_instance($type)->from_literal_or_die(@_);
}

=for html <a name="detach_process"></a>

=head2 static detach_process() : int

Forks, closes tty, stdin, out, etc.  Returns child pid to parent, and child
gets undef.

=cut

sub detach_process {
    my(undef) = @_;
    my($pid) = fork;
    die("fork: $!")
	unless defined($pid);
    return $pid
	if $pid;
    # Child
    open(STDIN, '< /dev/null');
    open(STDOUT, '+> /dev/null');
    open(STDERR, '>&STDOUT');
    eval {
	require POSIX;
	POSIX::setsid();
    };
    return;
}

=for html <a name="email_file"></a>

=head2 email_file(string email, string subject, string file_name)

Sends I<file_name> to I<email> with I<subject>.  Content type is determined
from suffix of I<file_name>.  File is always an attachment.

=cut

sub email_file {
    my($self, $email, $subject, $file_name) = @_;
    _email(
	$self, $email, $subject,
	sub {
	    my($msg) = @_;
	    $msg->set_content_type('multipart/mixed');
	    return $msg->attach(
		Bivio::IO::File->read($file_name),
		Bivio::MIME::Type->from_extension($file_name),
		$file_name, -T $file_name ? 0 : 1,
	    );
	},
    );
    return;
}

=for html <a name="email_message"></a>

=head2 email_message(string email, string subject, string_ref message)

Sends I<message> to I<email> with I<subject>.  Sends as simple body.

=cut

sub email_message {
    my($self, $email, $subject, $message) = @_;
    _email(
	$self, $email, $subject,
	sub {
	    return shift->set_body($message);
	},
    );
    return;
}

=for html <a name="finish"></a>

=head2 finish(boolean abort)

Calls L<commit_or_rollback|"commit_or_rollback"> and undoes setup.

=cut

sub finish {
    my($self, $abort) = @_;
    my($fields) = $self->[$_IDI];
    $self->commit_or_rollback($abort);
    $self->get_request->process_cleanup;
    Bivio::SQL::Connection->set_dbi_name($fields->{prior_db})
	if $fields->{prior_db};
    return;
}

=for html <a name="get_request"></a>

=head2 static get_request() : Bivio::Agent::Request

If called with an instance, same as $self-E<gt>get('req').  If called
statically, returns Bivio::Agent::Request-E<gt>get_current or dies
if no request.

=cut

sub get_request {
    my($self) = @_;
    if (ref($self)) {
	$self->setup() unless $self->unsafe_get('req');
        return $self->get('req');
    }
    my($req) = Bivio::Agent::Request->get_current;
    Bivio::Die->die('no request') unless $req;
    return $req;
}

=for html <a name="group_args"></a>

=head2 static group_args(string group_size, array_ref args) : array_ref

Returns an array of I<group_size> tuples (array_refs).  Calls
L<usage_error|"usage_error"> if I<args> not modulo I<group_size>.

I<args> is modified.

=cut

sub group_args {
    my($proto, $group_size, $args) = @_;
    $proto->usage_error("arguments must come in $group_size-tuples")
	unless @$args % $group_size == 0;
    my($res) = [];
    push(@$res, [splice(@$args, 0, $group_size)])
	while @$args;
    return $res;
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item daemon_log_file : string (named, required)

Name of the log file for the daemon process.  Will be passed to
L<Bivio::IO::Log::file_name|Bivio::IO::Log/"file_name">, so may be relative.
The log file is openned at each write to avoid collisions and to make log
rotation easier.

=item daemon_max_children : int [1] (named)

Number of children for the worker.  This creates a single queue.

=item daemon_max_child_run_seconds : int [0] (named)

Maximum elapsed run-time in seconds for a single process.  If zero, no maximum.
If greater than zero, child will be killed with TERM after run-time exceeded.

=item daemon_max_child_term_seconds : int [0] (named)

Elapsed run-time after kill TERM, before kill KILL is sent to the child.

=item daemon_sleep_after_reap : int [0] (named)

If 0, then L<run_daemon|"run_daemon"> calls C<wait> and blocks forever
until any children exit.  This is normal behavior.

If greater than 0, then childred are reaped by polling C<waitpid> with
C<POSIX::WNOHANG>.  After all children are reaped, the reaper (run_daemon)
sleeps for I<daemon_sleep_after_reap> before doing anything else.

=item daemon_sleep_after_start : int [60] (named)

Sleep after starts and before retries.

=item lock_directory : string [/tmp]

Where L<lock_action|"lock_action"> directories are created.  Must be absolute,
writable directory.

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    Bivio::Die->die($cfg->{lock_directory}, ': not a writable directory')
	unless length($cfg->{lock_directory})
	    && -w $cfg->{lock_directory} && -d _;
    Bivio::Die->die($cfg->{lock_directory}, ': not absolute')
	unless File::Spec->file_name_is_absolute($cfg->{lock_directory});
    $_CFG = $cfg;
    return;
}

=for html <a name="initialize_fully"></a>

=head2 initialize_fully() : Bivio::Agent::Request

Same as initialize_ui(1).

=cut

sub initialize_fully {
    return shift->initialize_ui(1);
}

=for html <a name="initialize_ui"></a>

=head2 initialize_ui(boolean fully) : Bivio::Agent::Request

Initializes the UI and sets up the default facade.  This takes some time, so
classes should use this sparingly.  If I<fully> is true, initializes all
facades.  Otherwise, only initializes the default facade, and does not setup
tasks for execution.

=cut

sub initialize_ui {
    my($self, $fully) = @_;
    my($req) = $self->get_request;
    Bivio::IO::ClassLoader->simple_require('Bivio::Agent::Dispatcher');
    Bivio::Agent::Dispatcher->initialize(!$fully);
    $req->setup_all_facades
	if $fully;
    Bivio::UI::Facade->setup_request(undef, $req);
    $req->put_durable(
	task => Bivio::Agent::Task->get_by_id($req->get('task_id')))
	if $req->unsafe_get('task_id');
    return $req;
}

=for html <a name="is_loadavg_ok"></a>

=head2 is_loadavg_ok() : boolean

Returns TRUE if the machine load is below a configurable
threshold.

TODO: Make threshold configurable

=cut

sub is_loadavg_ok {
    my($line) = Bivio::IO::File->read('/proc/loadavg');
    my(@load) = $$line =~ /^([\d\.]+)\s+([\d\.]+)\s+([\d\.]+)/;
    return $load[0] < 4 ? 1 : 0;
}

=for html <a name="lock_action"></a>

=head2 static lock_action(code_ref op, string action) : any

Creates a file lock for I<name> in /tmp/.  If I<name> is undef,
uses C<caller> subroutine name.  The usage is:

    sub my_action {
	my($self, ...) = @_;
	return Bivio::ShellUtil->lock_action(sub {
	     do something;
	});
    }

Prints a warning of the lock couldn't be obtained.  If I<op> dies,
rethrows die after removing lock.

The lock is a directory, and is owned by process.  If that process dies,
the lock is removed and re-acquired by this process.

Returns the result of $op if lock was obtained and I<op> executed without
dying.  Returns () if lock could not be acquired.


B<DEPRECATED USAGE BELOW>

=head2 DEPRECATED static lock_action(string action) : string

Creates a file lock for I<action> in I<lock_directory>.  If I<action> is undef,
uses C<caller> sub.  The usage is:

    sub my_action {
	my($self, ...) = @_;
	return
	    unless $self->lock_action;
    }

This method forks a new process and returns true in the child process.
The parent waits for the child and returns.  There is no timeout, so
child must be designed to be robust.

Catches TERM signal and resignals (to previous handler) bug first removes the
lock.

=cut

sub lock_action {
    my(undef, $op, $name) = @_;
    return _deprecated_lock_action($op || (caller(1))[3])
	unless ref($op) eq 'CODE';
    my($lock_dir, $lock_pid) = _lock_files($name || (caller(1))[3]);
    for my $retry (1, 0) {
	last if mkdir($lock_dir, 0700);
	unless ($retry) {
	    Bivio::IO::Alert->warn(
		$lock_dir, ': unable to delete lock for dead process');
	    return _lock_warning($lock_dir);
	}
	my($pid, $host) = split(/\s+/, ${Bivio::IO::File->read($lock_pid)});
	return _lock_warning($lock_dir)
	    if ($host && $host ne Sys::Hostname::hostname())
		|| _process_exists($pid);
	Bivio::IO::Alert->warn(
	    $pid, ": process doesn't exist, removing ", $lock_dir);
	# Don't test results, because there may be contention
	unlink($lock_pid);
	rmdir($lock_dir);
    }
    # Write host after pid to be backwards compatible with just pid format.
    Bivio::IO::File->write($lock_pid, $$ . ' ' . Sys::Hostname::hostname());
    my($prev) = $SIG{TERM};
    local($SIG{TERM}) = sub {
	unlink($lock_pid);
	rmdir($lock_dir);
	$SIG{TERM} = $prev;
	kill('TERM', $$);
	return;
    };
    my($die);
    my(@res) = Bivio::Die->catch($op, \$die);
    unlink($lock_pid);
    rmdir($lock_dir);
    $die->throw
	if $die;
    return @res;
}

=for html <a name="lock_realm"></a>

=head2 lock_realm()

Locks the current realm.  Dies if general realm is auth_realm.
Handles re-locking existing realm.

=cut

sub lock_realm {
    my($self) = @_;
    my($req) = $self->get_request;
    Bivio::Die->die("can't lock general realm")
	    if $req->get('auth_realm')->get('type')
		    == Bivio::Auth::RealmType->GENERAL();
    Bivio::Biz::Model->get_instance('Lock')->execute_unless_acquired($req);
    return;
}

=for html <a name="main"></a>

=head2 static main(array argv) : string_ref

Parses its arguments.  If I<argv[0]> contains is a valid public
method (definition: begins with a letter), will call it.
The rest of the arguments are passed verbatim
to this method.  If an error occurs, L<usage|"usage"> is called.

Global options precede the command and are set on the instance.

Returns the result as a string_ref if there is a result and wantarray is true.
This backward compatible feature was added to ease testing.

=cut

sub main {
    my($proto, @argv) = @_;
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
    my($p) = $0;
    $p =~ s!.*/!!;
    $p =~ s!\.\w+$!!;
    $self->put(program => $p);

    my($cmd, $res);
    my($die) = Bivio::Die->catch(sub {
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
	    my($log) = $self->use('Bivio::IO::Log')->file_name(
		$_CFG->{daemon_log_file} || "$p.log");
	    Bivio::IO::Alert->info('logging to: ', $log);
	    Bivio::IO::Alert->set_printer('FILE', $log);
	    if ($pid = $self->detach_process) {
		$res = "$pid\n";
		$self->SUPER::delete(qw(output email req));
	    }
	}
	$die = Bivio::Die->catch(sub {
	    $res = $self->$cmd(@argv);
	}) unless $pid;
    }
    $fields->{in_main} = 0;

    # Don't finish if setup never called.
    $self->finish($die ? 1 : 0)
	if $self->unsafe_get('req');;
    if ($die) {
	# Email error and re-throw
	$self->put(result_type => undef,
		result_subject => 'ERROR from: '.$self->command_line);
	_result_email($self, $cmd, $die->as_string);
	if ($self->unsafe_get('live')) {
	    Bivio::IO::Alert->warn($die);
	    return;
	}
	$die->throw();
	# DOES NOT RETURN
    }
    return $res
	if $res = $self->result($cmd, $res) and wantarray;
    return;
}

=for html <a name="model"></a>

=head2 model(any model, any query) : Bivio::Biz::Model

Instantiates I<model> and loads/processes I<query> if supplied.

=cut

sub model {
    my($self, $name, $query) = @_;
    my($m) = Bivio::Biz::Model->new($self->get_request, $name);
    return $m
	unless $query;
    if ($m->isa('Bivio::Biz::FormModel')) {
	$m->process($query);
    }
    elsif ($m->isa('Bivio::Biz::ListModel')) {
	$m->unauth_load_all($query);
	$m->set_cursor(0);
    }
    elsif ($m->isa('Bivio::Biz::PropertyModel')) {
	$m->unauth_load_or_die($query);
    }
    else {
	Bivio::Die->die($m, ': does not support query argument: ', $query);
    }
    return $m;
}

=for html <a name="piped_exec"></a>

=head2 static piped_exec(string command, string input, boolean ignore_exit_code) : string_ref

=head2 static piped_exec(string command, string_ref input, boolean ignore_exit_code) : string_ref

Runs I<command> with I<input> (or empty input) and returns output.
I<input> may be C<undef>.

Throws exception if it can't write the input. Throws exception if the
command returns a non-zero exit result unless ignore_exit_code is
specified.  The L<Bivio::Die|Bivio::Die> has an I<exit_code> attribute.

=cut

sub piped_exec {
    my(undef, $command, $input, $ignore_exit_code) = @_;
    my($in) = ref($input) ? $input : \$input;
    $$in = '' unless defined($$in);
    my($pid) = open(IN, "-|");
    defined($pid) || die("fork: $!");
    unless ($pid) {
	open(OUT, "| exec $command") || die("open $command: $!");
	print OUT $$in;
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
	Bivio::Die->throw_die('DIE', {
	    message => 'command died with non-zero status',
	    entity => $command,
	    input => $in,
	    output => \$res,
	    exit_code => $?,
	}) unless $ignore_exit_code;
    }
    return \$res;
}

=for html <a name="piped_exec_remote"></a>

=head2 static piped_exec_remote(string host, string command, string input, boolean ignore_exit_code) : string_ref

=head2 static piped_exec_remote(string host, string command, string_ref input, boolean ignore_exit_code) : string_ref

Run I<command> remotely using C<ssh>.  Returns result.  Assumes remote shell
understands single quote escaping.

=cut

sub piped_exec_remote {
    my($self, $host, $command, $input, $ignore_exit_code) = @_;
    if (defined($host)) {
	$command =~ s/'/'\''/g;
	$command = "ssh $host '($command) && echo OK$$'";
    }
    my($res) = $self->piped_exec($command, $input, $ignore_exit_code);
    Bivio::Die->throw_die('DIE', {
	message => 'remote command failed',
	host => $host,
	entity => $command,
	output => $res,
    }) unless $$res =~ s/OK$$\n// || $ignore_exit_code;
    return $res;
}

=for html <a name="print"></a>

=head2 print(any arg, ...) : int

Writes output to STDERR.  Returns result of print.
This method may be overriden.

=cut

sub print {
    shift;
    return print(STDERR @_);
}

=for html <a name="put"></a>

=head2 static put(string key, string value, ...)

=head2 put(string key, string value, ...) : Bivio::Collection::Attributes

If called statically, has no effect.  Otherwise, just calls
L<Bivio::Collection::Attributes::put|Bivio::Collection::Attributes/"put">.

=cut

sub put {
    my($self) = shift;
    return unless ref($self);
    return $self->SUPER::put(@_);
}

=for html <a name="put_request"></a>

=head2 put_request(Bivio::Agent::Request req) : self

Puts I<req> on I<self> and modifies other values appropriately.
Sets the current request to I<req>.

=cut

sub put_request {
    my($self, $req) = @_;
    return $self->put(req => $req);
}

=for html <a name="read_file"></a>

=head2 static read_file(string file_name) : string_ref

DEPRECATED: See L<Bivio::IO::File::read|Bivio::IO::File/"read">

=cut

sub read_file {
    my(undef, $file_name) = @_;
    Bivio::IO::Alert->warn_deprecated('use Bivio::IO::File->read');
    return Bivio::IO::File->read($file_name);
}

=for html <a name="read_input"></a>

=head2 read_input() : string_ref

Returns the contents if I<input> argument.  If no argument, reads
from STDIN.  If I<input> is a ref, just return that.

=cut

sub read_input {
    my($self) = @_;
    my($input) = $self->get('input');
    return ref($input) ? $input : Bivio::IO::File->read($input);
}

=for html <a name="readline_stdin"></a>

=head2 readline_stdin(string prompt) : string

Prints I<prompt>, and returns answer stripped of leading and trailing
whitespace.

=cut

sub readline_stdin {
    my($self, $prompt) = @_;
    $self->print($prompt);
    my $answer = <STDIN>;
    chomp($answer);
    $answer =~ s/^\s+|\s+$//g;
    return $answer;
}

=for html <a name="ref_to_string"></a>

=head2 static ref_to_string(any ref) : string_ref

B<DEPRECATED: Use Bivio::IO::Ref directly.>

=cut

sub ref_to_string {
    my(undef, $ref) = @_;
    return Bivio::IO::Ref->to_string($ref);
}

=for html <a name="result"></a>

=head2 result(string cmd, string_ref res) : string_ref

=head2 result(string cmd, string res) : string_ref

Processes I<res> by sending via I<email> and writing to I<output>
or printing to STDOUT.  Returns a reference to result or undef.

=cut

sub result {
    my($self, $cmd, $res) = @_;
    $res = _result_ref($self, $res);
    return undef
	unless $res;

    # If we write email or output, then don't write to STDOUT.
    print(STDOUT $$res)
	unless _result_email($self, $cmd, $res)
	+ _result_output($self, $cmd, $res);
    return $res;
}

=for html <a name="run_daemon"></a>

=head2 run_daemon(code_ref next_command, string cfg_name)

Starts a collection of processes using config defined by
I<cfg_name> (see L<handle_config|"handle_config">.

=cut

sub run_daemon {
    my($self, $next_command, $cfg_name) = @_;
    $self->get_request;
    my($cfg) = Bivio::IO::Config->get($cfg_name);
    # Makes log rotating simple: All processes share a log
    Bivio::IO::Alert->set_printer(
	'FILE',
	$self->use('Bivio::IO::Log')->file_name($cfg->{daemon_log_file}),
    ) if $cfg->{daemon_log_file};
    _check_cfg($cfg, $cfg_name);
    my($children) = {};
    while (1) {
	my($max_duplicates) = $cfg->{daemon_max_children};
	while (keys(%$children) < $cfg->{daemon_max_children}) {
	    my($args) = $next_command->();
	    last unless $args;
	    _reap_daemon_children($children, 0, 0, $cfg);
	    if (grep(
		Bivio::IO::Ref->nested_equals($args, $_->{args}),
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

=for html <a name="set_realm_and_user"></a>

=head2 static set_realm_and_user(any realm, any user) : self

Sets the I<realm> and I<user> on L<get_request|"get_request">.
If I<realm> is C<undef>, sets to General realm.
If I<user> is C<undef> and not general realm, calls
L<set_user_to_any_online_admin|"set_user_to_any_online_admin">.

=cut

sub set_realm_and_user {
    my($self, $realm, $user) = @_;
    $realm = Bivio::Auth::Realm->get_general()
	unless defined($realm);
    my($req) = $self->get_request;
    $req->set_realm($realm);

    if (defined($user)) {
	$req->set_user($user);
	return $self;
    }

    # $realm may be a string (name or id), so must get to check type
    $self->set_user_to_any_online_admin
	    unless $req->get('auth_realm')->get_type
		    == Bivio::Auth::RealmType->GENERAL();
    return $self;
}

=for html <a name="set_user_to_any_online_admin"></a>

=head2 static set_user_to_any_online_admin() : Bivio::Biz::Model::RealmOwner

Sets the user to first_admin on I<self> and I<req>.  Returns the
first admin.

=cut

sub set_user_to_any_online_admin {
    my($self) = @_;
    my($req) = $self->get_request;
    $req->set_user(
	    Bivio::Biz::Model->new($req, 'RealmUser')->get_any_online_admin);
    my($user) = $req->get('auth_user');
    $self->put(user => $user->get('name'));
    return $user;
}

=for html <a name="setup"></a>

=head2 setup() : self

Configures the environment for request.  Does nothing if already setup.

=cut

sub setup {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    $fields->{in_main} ? _setup_for_main($self) : _setup_for_call($self);
    return $self;
}

=for html <a name="unsafe_get"></a>

=head2 static unsafe_get(string name, ...) : undef

=head2 unsafe_get(string name, ...) : any

Return the attribute(s).  Returns default option values
or C<undef> if called statically.

Otherwise, just calls
L<Bivio::Collection::Attributes::unsafe_get|Bivio::Collection::Attributes/"unsafe_get">.

=cut

sub unsafe_get {
    my($self) = shift;
    return $self->SUPER::unsafe_get(@_) if ref($self);
    $_DEFAULT_OPTIONS{$self} = Bivio::Collection::Attributes->new(
	    _parse_options($self, []))
	    unless $_DEFAULT_OPTIONS{$self};
    return $_DEFAULT_OPTIONS{$self}->unsafe_get(@_);
}

=for html <a name="usage"></a>

=head2 static usage(array msg)

Dies with I<msg> followed by L<USAGE|"USAGE">.

=cut

sub usage {
    my($proto) = shift;
    $proto->usage_error(@_, "\n", $proto->USAGE(), $proto->OPTIONS_USAGE());
    # DOES NOT RETURN
}

=for html <a name="usage_error"></a>

=head2 usage_error(string msg, ...)

Terminates caller with a usage error.  Doesn't print usage.

TODO: Need to avoid stack trace.

=cut

sub usage_error {
    my($self) = shift;
    Bivio::IO::Alert->print_literally('ERROR: ', @_);
    Bivio::Die->throw_quietly('DIE');
    # DOES NOT RETURN
}

=for html <a name="write_file"></a>

=head2 static write_file(string file_name, string_ref contents)

DEPRECATED: See L<Bivio::IO::File::write|Bivio::IO::File/"write">

=cut

sub write_file {
    my(undef, $file_name, $contents) = @_;
    Bivio::IO::Alert->warn_deprecated('use Bivio::IO::File->write');
    return Bivio::IO::File->write($file_name, $contents);
}

#=PRIVATE METHODS

# _check_cfg(hash_ref cfg, string cfg_name)
#
# Asserts config is valid
#
sub _check_cfg {
    my($cfg, $cfg_name) = @_;
    while (my($k, $v) = each(%$cfg)) {
	next unless $k =~ /_(?:sleep|max|child)_/;
	next if $v =~ /^\d+$/ && $v >= 0;
	my($dv) = $_CFG->{Bivio::IO::Config->NAMED}->{$k};
	Bivio::IO::Alert->warn($v, ': bad value for ',
	    ($cfg_name ? "$cfg_name." : ''), $k,
	    '; using ', $dv);
	$cfg->{$k} = $dv;
    }
    if ($cfg->{daemon_max_child_run_seconds} > 0
	&& $cfg->{daemon_sleep_after_reap} <= 0) {
	Bivio::IO::Alert->warn('daemon_sleep_after_reap must be non-zero',
	    ' when daemon_max_child_run_seconds is non-zero; using 1 second');
	$cfg->{daemon_sleep_after_reap} = 1;
    }
    return;
}

# _compile_options(Bivio::ShellUtil self) : array
#
# Compiles the options string.  Returns a map of options to declarations
# as a hash_ref and an array_ref of the declarations.  A declaration
# is an array_ref (name, type, default).
#
sub _compile_options {
    my($self) = @_;
    my($options) = $self->OPTIONS;
    return ({}, []) unless $options && keys(%$options);

    my($map) = {};
    my($opts) = [];
    foreach my $k (keys(%$options)) {
	die("$k: options must be valid perl idents with at least on character")
	    unless $k =~ /^[a-z]\w+$/i;
	my($first) = substr($k, 0, 1);
	my($type, $default) = @{$options->{$k}};
	my($opt) = [$k, Bivio::Type->get_instance($type)];
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

# _deprecated_lock_action(string action) : boolean
#
# Implements deprecated form of lock_action.
#
sub _deprecated_lock_action {
    my($action) = @_;
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

sub _email {
    my($self, $to_email, $subject, $body) = @_;
    Bivio::IO::ClassLoader->simple_require(
	'Bivio::Mail::Outgoing',
	'Bivio::MIME::Type',
    );
    my($msg) = Bivio::Mail::Outgoing->new;
    my($req) = $self->get_request;
    $msg->set_recipients($to_email, $req);
    $msg->set_header('Subject', $subject);
    $msg->set_header('To', $to_email);
    $msg->set_from_with_user($req);
    $body->($msg);
    $msg->send($req)
        unless $self->unsafe_get('noexecute');
    return;
}

# _initialize(self, array_ref argv) : self
#
# Initializes the instance with the appropriate params.
#
sub _initialize {
    my($self, $argv) = @_;
    $argv ||= [];
    my($orig_argv) = [@$argv];
    $self->[$_IDI] ||= {};
    $self->put(
	%{_parse_options($self, $argv)},
	argv => $orig_argv,
    );
    return $self;
}

# _lock_files(string name) : array
#
# Returns the $name converted to (lock_dir, lock_pid)
#
sub _lock_files {
    my($name) = @_;
    # Strip illegal chars
    $name =~ s{@{[Bivio::Type->get_instance('FileName')->ILLEGAL_CHAR_REGEXP]}+}{}og;
    my($d) = File::Spec->catdir($_CFG->{lock_directory}, "$name.lockdir");
    return ($d, File::Spec->catfile($d, 'pid'));
}

# _lock_warning(string lock_dir) : int
#
# Prints warning with lock_dir's age.  Returns 0
#
sub _lock_warning {
    my($lock_dir) = @_;
    Bivio::IO::Alert->warn($lock_dir, ': not acquired; lock age=',
	time - (stat($lock_dir))[9],
	's',
    );
    return;
}

# _method_ok(Bivio::ShellUtil self, string method) : boolean
#
# Returns true if the public method exists in subclass or if the
# method is 'usage'.
#
sub _method_ok {
    my($self, $method) = @_;
    return 0 unless $method =~ /^([a-z]\w*)$/i;
    return 0 if $method =~ /^handle_/;
    return 1 if $method eq 'usage';
    foreach my $c (ref($self), @{$self->inheritance_ancestor_list}) {
	last if $c eq __PACKAGE__;
#TODO: Need to deprecate calls which __PACKAGE__->can($method) && $c->can.
	return 1 if $c->can($method);
    }
    return 0;
}

# _monitor_daemon_children(hash_ref children, hash_ref cfg)
#
# Monitor children max_time if daemon_max_child_run_seconds is greater than
# zero.
#
sub _monitor_daemon_children {
    my($children, $cfg) = @_;
    return unless $cfg->{daemon_max_child_run_seconds} > 0;
    my($t) = time;
    while (my($pid, $child) = each(%$children)) {
	next if $t < $child->{max_time};
	my($sig) = $child->{kill_term}++ ? 'KILL' : 'TERM';
	kill($sig, $pid);
	Bivio::IO::Alert->info("Sent SIG$sig: pid=", $pid, ' args=',
	    join(' ', splice(@{$child->{args}}, 2)));
	$child->{max_time} = $t + $cfg->{daemon_max_child_term_seconds}
    }
    return;
}

# _parse_options(Bivio::ShellUtil self, array_ref argv) : hash_ref
#
# Returns the options that were set.
#
sub _parse_options {
    my($self, $argv) = @_;
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
    $res->{output} = Bivio::IO::File->absolute_path($res->{output})
	if defined($res->{output}) && $res->{output} ne '-';
    _trace($res) if $_TRACE;
    return $res;
}

# _parse_option_value(Bivio::ShellUtil self, array_ref opt, string ) : hash_ref
#
# Returns the options that were set.
#
sub _parse_option_value {
    my($self, $opt, $value) = @_;
    return $value
	if ref($value) || !defined($value);
    my($v, $e) = $opt->[1]->from_literal($value);
    $self->usage("-$opt->[0] '$value': ", $e->get_long_desc)
	if $e;
    return $v;
}

# _parse_realm(Bivio::ShellUtil self, string attr) : string
#
# Returns the id or undef for realm.
#
sub _parse_realm {
    my($self, $attr) = @_;
    return undef
	unless my $realm = $self->unsafe_get($attr);
    my($ro) = $self->model('RealmOwner');
    $self->usage_error($realm, ': no such ', $attr)
	unless $ro->unauth_load_by_email_id_or_name($realm);
    return $ro;
}

# _process_exists(string pid) : boolean
#
# Returns true if $pid exists
#
sub _process_exists {
    my($pid) = @_;
    $! = undef;
    return kill(0, $pid) || $! != POSIX::ESRCH() ? 1 : 0;
}

# _reap_daemon_children(hash_ref children, int stopped, int sleep, hash_ref cfg)
#
# Reap children without blocking
#
sub _reap_daemon_children {
    my($children, $stopped, $sleep, $cfg) = @_;
    while (1) {
	if ($stopped > 0) {
	    if (my $child = delete($children->{$stopped})) {
		Bivio::IO::Alert->info('Stopped: pid=', $stopped, ' args=',
		    join(' ', splice(@{$child->{args}}, 2)));
	    }
	    else {
		Bivio::IO::Alert->warn($stopped, ': unknown pid');
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

# _result_email(Bivio::ShellUtil self, string cmd, string_ref res) : boolean
#
# Emails the result if there is an email option (returns true in that case).
#
sub _result_email {
    my($self, $cmd, $res) = @_;
    my($email) = $self->unsafe_get('email');
    return 0 unless $email;

    my($name, $type, $subject) = $self->unsafe_get(
	    qw(result_name result_type result_subject));
    _email(
	$self,
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

# _result_output(self, string cmd, string_ref res) : boolean
#
# Returns true if there is an output option and it is written to a file.
#
sub _result_output {
    my($self, $cmd, $res) = @_;
    my($output) = $self->unsafe_get('output');
    return 0 unless $output;

    Bivio::IO::File->write($output, $res);
    return 1;
}

# _result_ref(self, any res) : scalar_ref
#
# Returns a scalar reference to the result or undef if no result to print.
# Will print any structure.
#
sub _result_ref {
    my($self, $res) = @_;
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

# _setup_for_call(self)
#
# Called from within a program.  Request must be setup already or dies.
# Doesn't allow certain attributes.  Sets user and realm only if passed
# explicitly.
#
sub _setup_for_call {
    my($self) = @_;
    my($req) = Bivio::Agent::Request->get_current;
    Bivio::Die->die(ref($self), ": called without first creating a request")
	unless $req;
    $req->set_realm($self->get('realm')) if $self->unsafe_get('realm');
    $req->set_user($self->get('user')) if $self->unsafe_get('user');
    foreach my $attr (qw(db)) {
	Bivio::Die->die($attr, ': cannot pass to ', ref($self), ' call')
	    if $self->unsafe_get($attr);
    }
    $self->put_request($req);
    return;
}

# _setup_for_main(self)
#
# Called from "main".  Always creates a Job::Request.  Initializes db.
# Sets realm/user.
#
sub _setup_for_main {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    my($db, $user, $realm) = $self->unsafe_get(qw(db user realm));
    $self->use('Bivio::Test::Request');
    my($p) = $self->use('Bivio::SQL::Connection')->set_dbi_name($db);
    $fields->{prior_db} = $p unless $fields->{prior_db};
    $self->put_request(Bivio::Test::Request->get_instance)
        unless $self->unsafe_get('req');
    $self->set_realm_and_user(map(_parse_realm($self, $_), qw(realm user)));
    return;
}

# _start_daemon_child(self, array_ref args, hash_ref cfg) : int
#
# Starts child process, appending to log.  Returns pid.
#
sub _start_daemon_child {
    my($self, $args, $cfg) = @_;
    # Force a reconnect for both child and parent; avoids errors in
    # logs for parent.
    Bivio::SQL::Connection->disconnect;
    Bivio::IO::Alert->reset_warn_counter;
 RETRY: {
	my($child) = fork;
	unless (defined($child)) {
	    Bivio::IO::Alert->warn($args,
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
	Bivio::IO::Alert->info('Starting: pid=', $$, ' args=',
	    join(' ', @$args[2 .. $#$args]));
	# Reset so we can send signals in _monitor_daemon_children()
	local($SIG{TERM}) = 'DEFAULT';
        $args->[0]->main(@$args[1 .. $#$args]);
	CORE::exit(0);
    }
}

=head1 COPYRIGHT

Copyright (c) 2000-2006 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
