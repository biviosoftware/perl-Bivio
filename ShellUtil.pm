# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::ShellUtil;
use strict;
$Bivio::ShellUtil::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::ShellUtil::VERSION;

=head1 NAME

Bivio::ShellUtil - base class for command line utilities

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
options (I<user>, I<db>, and I<realm>).  It is called
implicitly by L<get_request|"get_request">

Options precede the command.  See L<OPTIONS|"OPTIONS">.

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

=item email : string [undef]

Where to mail the output.  Uses I<result_type> and I<result_name>,
if available.

=item force : boolean [0]

If true, L<are_you_sure|"are_you_sure"> will always return true.

=item noexecute : boolean [1]

Won't execute any "modifying" operations.  Will not call
commit on termination.

=item program : string

Name of the program sans suffix and directory.

=item output : string

Name of the file to write the output to.

=item quiet : boolean [0]

B<DEPRECATED: Use Trace instead.>

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
	  -email - who to mail the results to (may be a comma separated list)
          -force - don't ask "are you sure?"
          -input - a file to read from ("-" is STDIN)
          -noexecute - don't commit
          -output - a file to write the output to ("-" is STDOUT)
	  -realm - realm_id or realm name
	  -user - user_id or user name

=cut

sub OPTIONS_USAGE {
    return <<'EOF';
options:
        -db - name of database connection
        -email - who to mail the results to (may be a comma separated list)
        -force - don't ask "are you sure?"
        -input - a file to read from ("-" is STDIN)
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
	email => ['Text', undef],
	force => ['Boolean', 0],
	noexecute => ['Boolean', 0],
	quiet => ['Boolean', 0],  # DEPRECATED, use Trace instead
	realm => ['Name', undef],
	user => ['Name', undef],
        input => ['Line', '-'],
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
	email => ['Text', undef],
	force => ['Boolean', 0],
	input => ['Line', '-'],
	noexecute => ['Boolean', 0],
	quiet => ['Boolean', 0],
	realm => ['Name', undef],
	user => ['Name', undef],
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
use Bivio::Die;
use Bivio::IO::File;
use Bivio::IO::Trace;
use Bivio::Type;
use Bivio::TypeError;
use Data::Dumper ();

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::ShellUtil

=head2 static new(array_ref argv) : Bivio::ShellUtil

Initializes a new instance with these command line arguments.

=cut

sub new {
    my($proto, $argv) = @_;
    my($self) = Bivio::Collection::Attributes::new($proto);
    $argv ||= [];
    my($orig_argv) = [@$argv];
    $self->{$_PACKAGE} = {};
    $self->internal_put(_parse_options($self, $argv));
    $self->put(argv => $orig_argv);
    return $self;
}

=head1 METHODS

=cut

=for html <a name="are_you_sure"></a>

=head2 static are_you_sure()

=head2 static are_you_sure(string prompt)

Writes I<prompt> (default: "Are you sure?") to STDERR.  User must
answer "yes", on STDIN or the routine throws an exception.

Always returns in STDIN is not a tty (-t STDIN returns false).

It is assumed STDERR is set up for autoflushing.

=cut

sub are_you_sure {
    my($proto, $prompt) = @_;

    # Not a tty?
    return unless -t STDIN;

    # Force?
    return if ref($proto) && $proto->unsafe_get('force');

    # Ask
    $prompt ||= 'Are you sure?';
    print STDERR $prompt, " (yes or no) ";

    # Get answer stripping spaces to be nice.
    my $answer = <STDIN>;
    $answer =~ s/\s+//g;
    die("Operation aborted\n") unless $answer eq 'yes';

    # Yes answer
    return;
}

=for html <a name="command_line"></a>

=head2 command_line() : string

Returns the command line that was used to execute this command.

=cut

sub command_line {
    my($self) = @_;
    return ref($self)
	    ? join(' ', $self->get('program'), @{$self->get('argv')})
		    : 'N/A';
}

=for html <a name="finish"></a>

=head2 finish(boolean abort)

Commit (if !noexecute) and clean up work of setup.

=cut

sub finish {
    my($self, $abort) = @_;
    my($fields) = $self->{$_PACKAGE};
    Bivio::IO::ClassLoader->simple_require('Bivio::Agent::Task');
    $self->unsafe_get('noexecute') || $abort
	    ? Bivio::Agent::Task->rollback($self->get('req'))
		    : Bivio::Agent::Task->commit($self->get('req'));
    return Bivio::SQL::Connection->set_dbi_name($fields->{prior_db});
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

=for html <a name="initialize_ui"></a>

=head2 initialize_ui()

Initializes the UI and sets up the default facade.  This takes some,
so classes should use this sparingly.

=cut

sub initialize_ui {
    my($self) = @_;
    Bivio::IO::ClassLoader->simple_require('Bivio::Agent::Dispatcher');
    Bivio::Agent::Dispatcher->initialize;
    Bivio::Agent::HTTP::Location->setup_facade(undef, $self->get_request);
    return;
}

=for html <a name="main"></a>

=head2 static main(array argv)

Parses its arguments.  If I<argv[0]> contains is a valid public
method (definition: begins with a letter), will call it.
The rest of the arguments are passed verbatim
to this method.  If an error occurs, L<usage|"usage"> is called.

Global options precede the command and are set on the instance.

=cut

sub main {
    my($proto, @argv) = @_;
    local($|) = 1;
    my($self) = $proto->new(\@argv);

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
	    $res = $self->$cmd(@argv);
	}
	elsif (@argv) {
	    $self->usage($argv[0], ': unknown command');
	}
	else {
	    $self->usage('missing command');
	}
	return $res;
    });
    $self->finish($die ? 1 : 0) if $self->unsafe_get('req');;
    $die->throw() if $die;
    $self->result($cmd, $res);
    return;
}

=for html <a name="piped_exec"></a>

=head2 static piped_exec(string command) : string_ref

=head2 static piped_exec(string command, string input) : string_ref

=head2 static piped_exec(string command, string_ref input) : string_ref

Runs I<command> with I<input> (or empty input) and returns output.
I<input> may be C<undef>.

Throws exception if it can't write the input or if the command returns
a non-zero exit result.  The L<Bivio::Die|Bivio::Die> has an
I<exit_code> attribute.

=cut

sub piped_exec {
    my(undef, $command, $input) = @_;
    my($in) = ref($input) ? $input : \$input;
    $$in = '' unless defined($$in);
    my($pid) = open(IN, "-|");
    defined($pid) || die("fork: $!");
    unless ($pid) {
	open(OUT, "| exec $command") || die("open $command: $!");
	print OUT $$in;
	close(OUT);
	# If there is a signal, return 99.  Otherwise, return exit code.
	CORE::exit($? ? ($? >> 8) ? ($ >> 8) : 99 :  0);
    }
    local($/) = undef;
    my($res) = <IN>;
    $res ||= '';
    close(IN) || Bivio::Die->throw_die('DIE', {
	message => 'command died with non-zero status',
	entity => $command,
	exit_code => $?,
    });
    return \$res;
}

=for html <a name="print"></a>

=head2 print(any arg, ...) : int

Writes output to STDOUT.  Returns result of print.
This method may be overriden.

=cut

sub print {
    shift;
    return print STDOUT @_;
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
from STDIN.

=cut

sub read_input {
    my($self) = @_;
    return Bivio::IO::File->read($self->get('input'));
}

=for html <a name="ref_to_string"></a>

=head2 static ref_to_string(any ref) : string_ref

Converts ref into a string.

=cut

sub ref_to_string {
    my(undef, $ref) = @_;
    my($dd) = Data::Dumper->new([$ref]);
    $dd->Indent(1);
    $dd->Terse(1);
    $dd->Deepcopy(1);
    my($res) = $dd->Dumpxs();
    return \$res;
}

=for html <a name="result"></a>

=head2 result(string cmd, string_ref res)

=head2 result(string cmd, string res)

Processes I<res> by sending via I<email> and writing to I<output>
or printing to STDOUT.

=cut

sub result {
    my($self, $cmd, $res) = @_;
    $res = _result_ref($res);
    return unless $res;

    # If we write email or output, then don't write to STDOUT.
    return if _result_email(@_) + _result_output(@_);
    print STDOUT $$res;
    return;
}

=for html <a name="setup"></a>

=head2 setup()

Configures the environment with a Job::Request and database
connection (if need be).

B<Doesn't configure the request if the db user isn't bivio.>

=cut

sub setup {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($db, $user, $realm) = $self->unsafe_get(qw(db user realm));

    Bivio::IO::ClassLoader->simple_require(qw{
        Bivio::Agent::Job::Request
        Bivio::Agent::TaskId
        Bivio::SQL::Connection
    });
    $fields->{prior_db} = Bivio::SQL::Connection->set_dbi_name($db);
    return unless Bivio::Ext::DBI->get_config($db)->{user} eq 'bivio';

    $realm = _parse_realm_id($self, 'realm');
    $user = _parse_realm_id($self, 'user');
    $self->put(req => Bivio::Agent::Job::Request->new({
	auth_id => $realm,
	auth_user_id => $user,
	task_id => Bivio::Agent::TaskId::SHELL_UTIL(),
    }));

    my($req) = $self->get('req');
    if ($realm && !$user) {
	# No user, but have a realm, so set a user
        $req->set_user(
		Bivio::Biz::Model::RealmOwner->new($req)->unauth_load_or_die(
			realm_id => Bivio::Biz::Model->new($req,
				'RealmAdminList')
			->get_first_admin(
				$self->get('req')->get('auth_realm')
				->get('owner'))));
    }
    return;
}

=for html <a name="unsafe_get"></a>

=head2 static unsafe_get(string name, ...) : undef

=head2 unsafe_get(string name, ...) : any

Return the attribute(s).  Returns C<undef> or empty array
if called statically.

Otherwise, just calls
L<Bivio::Collection::Attributes::unsafe_get|Bivio::Collection::Attributes/"unsafe_get">.

=cut

sub unsafe_get {
    my($self) = shift;
    return $self->SUPER::unsafe_get(@_) if ref($self);
    return () if wantarray;
    return undef;
}

=for html <a name="usage"></a>

=head2 static usage(array msg)

Dies with I<msg> followed by L<USAGE|"USAGE">.

=cut

sub usage {
    my($proto) = shift;
    Bivio::Die->die(
	    <<"EOF".$proto->USAGE().$proto->OPTIONS_USAGE());
ERROR: @{[join('', @_)]}
EOF
}

=for html <a name="verbose"></a>

=head2 verbose(any arg, ...)

B<DEPRECATED: Use Trace instead.>

=cut

sub verbose {
    my($self) = shift;
    Bivio::IO::Alert->warn_deprecated('use _trace()');
    return if $self->unsafe_get('quiet');
    $self->print(@_);
    return;
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
	die("$k: options must be valid perl idents")
		unless $k =~ /^[a-z]\w+$/i;
	my($first) = $k =~ /^(.)/;
	my($type, $default) = @{$options->{$k}};
	my($opt) = [$k, Bivio::Type->get_instance($type), $default];
	if (exists($map->{$first})) {
	    # Single char collision, mark for deletion below
	    die("option conflict '$first' and '$k'")
		    if $map->{$first}->[0] eq $first;
	    $map->{$first} = undef;
	}
	else {
	    $map->{$first} = $opt;
	}
	$map->{$k} = $opt;
	push(@$opts, $opt);
    }

    # Delete single chars which collided
    while (my($k, $v) = each(%$map)) {
	delete($map->{$k}) unless $v;
    }
    return ($map, $opts);
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
    my($can) = $self->can($method);
    return 0 unless $can;
    return 1 if $can eq \&{ref($self).'::'.$method};
    return 0 if ref($self) eq __PACKAGE__;
    return 1 if $method eq 'usage';
    return 0;
}

# _parse_options(Bivio::ShellUtil self, array_ref argv) : hash_ref
#
# Returns the options that were set.
#
sub _parse_options {
    my($self, $argv) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($res) = {};
    my($map, $opts) = _compile_options($self);
    $fields->{compiled_options} = $opts;
    $fields->{compiled_map} = $map;
    return unless %$map;

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
	$self->usage("-$k: missing an argument") unless @$argv;
	my($v, $e) = shift(@$argv);
	($v, $e) = $opt->[1]->from_literal($v);
	$self->usage("-$k: ", $e->get_long_desc) if $e;
	$res->{$opt->[0]} = $v;
    }

    # Set the (defined) defaults
    foreach my $opt (@$opts) {
	next if exists($res->{$opt->[0]});
	next unless defined($opt->[2]);
	$res->{$opt->[0]} = $opt->[2];
    }

    _trace($res) if $_TRACE;
    return $res;
}

# _parse_realm_id(Bivio::ShellUtil self, string attr) : string
#
# Returns the id or undef for realm.
#
sub _parse_realm_id {
    my($self, $attr) = @_;
    my($realm) = $self->unsafe_get($attr);
    return $realm unless defined($realm) && $realm !~ /^\d+$/;
    Bivio::IO::ClassLoader->simple_require('Bivio::Biz::Model');
    my($ro) = Bivio::Biz::Model->get_instance('RealmOwner')->new();
    $ro->unauth_load_or_die(name => $realm);
    return $ro->get('realm_id');
}

# _result_email(Bivio::ShellUtil self, string cmd, string_ref res) : boolean
#
# Emails the result if there is an email option (returns true in that case).
#
sub _result_email {
    my($self, $cmd, $res) = @_;
    my($email) = $self->unsafe_get('email');
    return 0 unless $email;

    Bivio::IO::ClassLoader->simple_require('Bivio::Mail::Outgoing');
    my($msg) = Bivio::Mail::Outgoing->new();
    my($name, $type) = $self->unsafe_get('result_name', 'result_type');
    $name ||= $cmd;
    $msg->set_recipients($email);
    $msg->set_header('Subject', $name.' generated by "'
	    .$self->command_line().'"');
    if ($type) {
	$msg->set_content_type('multipart/mixed');
	# Can't use -B and couldn't get IO::Scalar to work.
	# Just assume is binary
	$msg->attach($res, $type, $name, 1);
    }
    else {
	$msg->set_body($res);
    }
    $msg->send();
    return 1;
}

# _result_output(Bivio::ShellUtil self, string cmd, string_ref res) : boolean
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

# _result_ref(any res) : scalar_ref
#
# Returns a scalar reference to the result or undef if no result to print.
#
sub _result_ref {
    my($res) = @_;
    return undef unless defined($res);
    my($ref) = \$res;
    if (ref($res)) {
	unless (ref($res) eq 'SCALAR') {
	    Bivio::IO::Alert->warn('result is not a scalar: ', $res);
	    return undef;
	}
	$ref = $res;
    }
    return defined($$ref) && length($$ref) ? $ref : undef;
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
