# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::ShellUtil;
use strict;
$Bivio::ShellUtil::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

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

Options precede the command.  See L<OPTIONS|"OPTIONS">.

For an example, see L<Bivio::SQL::Util|Bivio::SQL::Util>.

=cut

=head1 CONSTANTS

=cut

=for html <a name="OPTIONS"></a>

=head2 OPTIONS : hash_ref

Returns a mapping of options to bivio types and default values.
For example,

    {
        quiet => ['Boolean', 0],
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
    return {};
}

=for html <a name="USAGE"></a>

=head2 USAGE : string

B<Subclasses should override this method.>

Returns the usage string, e.g.

    usage: b-db-util [options] command [args...]
    commands:
	   remote_sqlplus host db_login actions
	   copy_logs_to_standby
	   recover_standby
	   sql2csv file.sql [database [email]]
	   switch_logs_and_count_rows
    options:
           -q -- quiet mode

=cut

sub USAGE {
    return '';
}

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::Type;
use Bivio::TypeError;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;

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

=for html <a name="getopt"></a>

=head2 getopt(string name) : any

=head2 static getopt(string name) : undef

Return the value of the option.  If called statically, always returns
C<undef> (options can't be passed to classes).

=cut

sub getopt {
    my($self, $name) = @_;
    _trace($self->internal_get) if $_TRACE;
    return ref($self) ? $self->unsafe_get($name) : undef;
}

=for html <a name="main"></a>

=head2 static main(array argv) : int

Parses its arguments.  If I<argv[0]> contains is a valid public
method (definition: begins with a letter), will call it.
The rest of the arguments are passed verbatim
to this method.  If an error occurs, L<usage|"usage"> is called.

Global options precede the command and are set on the instance.

=cut

sub main {
    my($proto, @argv) = @_;
    Bivio::IO::Config->initialize(\@argv);

    local($|) = 1;
    my($self) = $proto->new(_parse_options($proto, \@argv));

    # Execute the method only if defined in subclass (except for usage)
    if (@argv && $argv[0] =~ /^([a-z]\w*)$/i && $self->can($1)
	   && (!__PACKAGE__->can($1) || $1 eq 'usage')) {
	shift(@argv);
	$self->$1(@argv);
    }
    else {
	$self->usage('unknown or missing command');
    }
}

=for html <a name="piped_exec"></a>

=head2 static piped_exec(string command) : string_ref

=head2 static piped_exec(string command, string input) : string_ref

=head2 static piped_exec(string command, string_ref input) : string_ref

Runs I<command> with I<input> (or empty input) and returns output.
I<input> may be C<undef>.

Throws exception if it can't write the input or if the command returns
a non-zero exit result.

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
	close(OUT) || die("write to $command failed: $!");
	CORE::exit(0);
    }
    local($/) = undef;
    my($res) = <IN>;
    $res ||= '';
    close(IN) || die("$res\n$command failed: $!");
    return \$res;
}

=for html <a name="usage"></a>

=head2 static usage(array msg)

Dies with I<msg> followed by L<USAGE|"USAGE">.

=cut

sub usage {
    my($proto) = shift;
    Bivio::DieCode::DIE()->die(<<"EOF".$proto->USAGE());
ERROR: @{[join('', @_)]}
EOF
}

#=PRIVATE METHODS

# _compile_options(string proto) : array
#
# Compiles the options string.  Returns a map of options to declarations
# as a hash_ref and an array_ref of the declarations.  A declaration
# is an array_ref (name, type, default).
#
sub _compile_options {
    my($proto) = @_;
    my($options) = $proto->OPTIONS;
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

# _parse_options(string proto, array_ref argv) : hash_ref
#
# Returns the options that were set.
#
sub _parse_options {
    my($proto, $argv) = @_;
    my($res) = {};
    my($map, $opts) = _compile_options($proto);
    return unless %$map;

    # Parse the options
    while (@$argv && $argv->[0] =~ /^-/) {
	my($k) = shift(@$argv);
	$k =~ s/^-//;
	my($opt) = $map->{$k};
	$proto->usage("-$k: unknown option") unless $opt;
	if ($opt->[1] eq 'Bivio::Type::Boolean') {
	    $res->{$opt->[0]} = 1;
	    next;
	}
	$proto->usage("-$k: missing an argument") unless @$argv;
	my($v, $e) = shift(@$argv);
	($v, $e) = $opt->[1]->from_literal($v);
	$proto->usage("-$k: ", $e->get_long_desc) if $e;
	$res->{$opt->[0]} = 1;
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

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
