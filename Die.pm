# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Die;
use strict;
$Bivio::Die::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::Die - dispatch die_handler in modules on stack

=head1 SYNOPSIS

    use Bivio::Die;
    Bivio::Die->catch(sub {});
    sub handle_die {
	my($proto, $die) = @_;
    }

=cut

use Bivio::Collection::Attributes;
@Bivio::Die::ISA = qw(Bivio::Collection::Attributes);

=head1 DESCRIPTION

C<Bivio::Die> manages per-instance/class handlers for C<die>.  When C<die> is
called, C<Bivio::Die> searches up the stack for calls to public
methods of instances and classes which can C<handle_die>.  The
C<handle_die> methods are called in LIFO order, i.e. the most recently
called to current.

C<handle_die> methods may change the die code, but they should not
call L<die|"die"> or C<CORE::die>.  This will result in an error state.

Classes do not register with this module.  Instead, the method
L<catch|"catch"> which sets C<$SIG{__DIE__}> locally is used.
This makes for clean interaction with L<Bivio::IO::Alert|Bivio::IO::Alert>,
which is the global C<$SIG{__DIE__}> registrant.

This module is policy neutral with respect to error handling.  It
holds errors and it is the responsibility of the L<catch|"catch"> caller
and C<handle_die> implementers to do something about the errors.


=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::DieCode;
use Bivio::IO::Alert;
use Bivio::IO::Config;
use Bivio::IO::Trace;
use Bivio::Type::Enum;
use UNIVERSAL ();

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_STACK_TRACE) = 0;
my($_STACK_TRACE_ERROR) = 0;
my($_CURRENT_SELF);
my($_IN_CATCH) = 0;
my($_IN_HANDLE_DIE) = 0;
Bivio::IO::Config->register({
    'stack_trace' => $_STACK_TRACE,
    'stack_trace_error' => $_STACK_TRACE_ERROR,
});

=head1 FACTORIES

=cut

=for html <a name="catch"></a>

=head2 catch(code sub) : Bivio::Die or undef

Installs a local C<$SIG{__DIE__}> handler, calls I<sub>.
If I<sub> succeeds without error, C<undef> is returned.
Otherwise, a C<Bivio::Die> object is returned.  These may
be chained, i.e. if there is a C<die> within a C<die>,
the first instance will be linked to the second and can
be retrieved with L<get_next|"get_next">.

The stack is unwound until this method (catch) is found and then we unwind
one more to allow the caller of catch to have a C<handle_die> routine.

If a call to C<handle_die> results in a C<die>, a new die
object will be created and chained on to the current die.

You may not call catch from within a die handler, because
C<$SIG{__DIE__}> is specifically disabled.

=cut

sub catch {
    my($proto, $sub) = @_;
    Bivio::Die->die(Bivio::DieCode::CATCH_WITHIN_DIE(),
	    {sub => $sub, program_error => 1}, (caller)[0], (caller)[2])
		if $_IN_HANDLE_DIE;
    $_IN_CATCH++;
    local($SIG{__DIE__}) = sub {
	my($msg) = @_;
	$_STACK_TRACE && print STDERR Carp::longmess($msg);
	_handle_die(_new_from_core_die($proto, Bivio::DieCode::DIE(),
		{message => $msg, program_error => 1}, caller));
    };
    my($self) = eval {
	&$sub();
	1;
    } ? undef : $_CURRENT_SELF;
    $_CURRENT_SELF = undef;
    $_IN_CATCH--;
    return $self;
}

=head1 METHODS

=cut

=for html <a name="as_string"></a>

=head2 as_string() : string

Returns Die object and all its subsequent errors as a string ending
in "\n".

=cut

sub as_string {
    my($self) = @_;
    my($res) = '';
    for (my($curr) = $self; $curr; $curr = $curr->get('next')) {
	eval {
	    return 0 if $curr->is_destroyed;
	    my($c, $a, $p, $f, $l) = $curr->get(
		'code', 'attrs', 'package', 'file', 'line');
	    my($m) = [$c];
	    if (%$a) {
		# Don't just "join", because we want Alert to call
		# as->string if appropriate.
		push(@$m, ': ', map {
		    ($_, ' => ', $a->{$_}, ', ')
		} sort keys %$a);
		pop(@$m);
	    }
	    $res .= Bivio::IO::Alert->format($p, $f, $l, undef, $m);
	    return 1;
	} || ($res .= 'ERROR: ' . $curr . "\n");
    }
    return $res;
}

=for html <a name="destroy"></a>

=head2 destroy()

Destroys self and removes from the current chain.  The initial error is not
actually destroyed, but is set in L<is_destroyed|"is_destroyed"> state.  This
allows L<catch|"catch"> to know there is an error while also knowing all errors
were handled.  I<code> is set to C<undef> which is the flag that this
instance was destroyed.

If self is not part of the current catch, then it is simply set to destroyed
and its next link is left untouched.

=cut

sub destroy {
    my($self) = @_;
    $self->put('code' => undef);

    # No current chain
    return unless $_CURRENT_SELF;

    # Head of chain
    if ($_CURRENT_SELF eq $self) {
	my($next) = $_CURRENT_SELF->get('next');
	$_CURRENT_SELF->put('next', undef);
	$_CURRENT_SELF = $next;
	return;
    }

    # Somewhere in the chain?
    my($curr, $next) = $_CURRENT_SELF;
    while ($next = $curr->get('next')) {
	next unless $next eq $self;
	$curr->put('next', $next->get('next'));
	$self->put('next' => undef);
	last;
    }

    # Not part of "current" chain.  Don't update next link.
    return;
}

=for html <a name="die"></a>

=head2 static die(Bivio::Type::Enum code, hash_ref attrs, string package, string file, int line)

Any of the parameters may be undef. Package and line will be filled in by this
module.  If you'd like to implement a module specific die, you might:

    sub die {
	my($self, $code, $msg) = @_;
	Bivio::Die->die(My::Package::DieCode->from_any($code),
		{msg => $msg, object => $self}, caller);
    }

C<caller> will be called in an array context and return the appropriate
attributes about the caller in the right order.  Note that
L<Bivio::Type::Enum::from_any|Bivio::Type::Enum/"from_any">
returns C<undef> if $code isn't found, so it is entirely safe.

If I<code> is C<undef>, it will be set to C<Bivio::DieCode::UNKNOWN>.
If I<code> is a string, it will be converted to a L<Bivio::DieCode>
if possible.

If I<attrs> is C<undef>, it will be set to the empty hash.
If I<attrs> is a not a reference, it will be set to C<{message => $attrs}>.
If I<attrs> is not a hash, it will be set to C<{attrs => $attrs}>.

=cut

sub die {
    my($proto, $code, $attrs, $package, $file, $line) = @_;
    $package ||= (caller)[0];
    $file ||= (caller)[1];
    $line ||= (caller)[2];
    unless (ref($attrs) eq 'HASH') {
	$attrs = defined($attrs)
		? !ref($attrs) ? {message => $attrs}
			:  {attrs => $attrs} : {};
    }
    if (defined($code)) {
	unless (ref($code) && UNIVERSAL::isa($code, 'Bivio::Type::Enum')) {
	    unless (eval {
		my($c) = Bivio::DieCode->from_any($code);
		$code = $c;
	    }) {
		$attrs = {code => $code, attrs => $attrs, program_error => 1};
		$code = Bivio::DieCode::INVALID_DIE_CODE();
	    };
	}
    }
    else {
	$code = Bivio::DieCode::UNKNOWN();
	$attrs->{program_error} = 1;
    }
    my($self) = _new($proto, $code, $attrs, $package, $line);
    CORE::die($_IN_CATCH ? "$self\n" : $self->as_string);
}

=for html <a name="handle_config"></a>

=head2 static handle_config(string class, hash cfg)

=over 4

=item stack_trace : boolean [false]

If true, will print a stack trace on L<die|"die">.

=item stack_trace_error : boolean [false]

If true, will print a stack trace on a L<die|"die"> which contains a
I<program_error> attribute which evaluates to I<true>.  I<program_error> is
set automatically for C<CORE::die> calls and other internal errors in
handling L<die|"die"> calls, e.g. die within die.

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_STACK_TRACE = $cfg->{stack_trace};
    $_STACK_TRACE_ERROR = $cfg->{stack_trace_error};
    $_STACK_TRACE_ERROR = 0 if $_STACK_TRACE;
    return;
}

=for html <a name="is_destroyed"></a>

=head2 is_destroyed() : boolean

Returns true if the instance was destroyed.

=cut

sub is_destroyed {
    return !shift->get('code');
}

#=PRIVATE METHODS

# _handle_die self
#
# Called from within $SIG{__DIE__} inside catch.  $_CURRENT_SELF is
# already created.  Calls the die handlers sequentially.  If errors
# occur, chains them on to $_CURRENT_SELF by calling _new_from_core_die.
#
sub _handle_die {
    $_IN_HANDLE_DIE++;
    eval {
	my($self) = @_;
	if ($_STACK_TRACE_ERROR) {
	    my($attrs) = $self->get('attrs');
	    print STDERR Carp::longmess($self->as_string)
		    if $attrs->{program_error};
	}
	my($i) = 0;
	my(@a);
	my($prev_proto) = '';
	my($stop) = -1;
	# Iterate until just one routine after catch
	while ($stop <= 0 && do { { package DB; @a = caller($i++) } } ) {
	    # Only start incrementing stop when "catch" is seen
	    $stop++ if $stop >= 0;
	    my($sub, $has_args) = @a[3,4];
	    # Only call if argument is to a public method in a module
	    defined($sub) && $sub =~ /::[a-z]\w+$/ && $has_args || next;
	    if ($sub eq "${_PACKAGE}::catch") {
		# This gives us one more loop iteration
		$stop++;
		next;
	    }
	    my($proto) = $DB::args[0];
	    UNIVERSAL::can($proto, 'handle_die') || next;
	    # Don't call twice if in same "entry" into module
	    $prev_proto ne $proto || next;
	    $prev_proto = $proto;
	    eval {
		&_trace("calling ", ref($proto) || $proto, "->handle_die")
		    if $_TRACE;
		$proto->handle_die($self);
		1;
	    } && next;
	    my($msg) = $@;
	    eval {
		&_trace($proto, "->handle_die: ", $msg) if $_TRACE;
	    };
	    $msg =~ / at (\S+|\(eval \d+\)) line (\d+)\.\n$/;
	    _new_from_core_die($self, Bivio::DieCode::DIE_WITHIN_HANDLE_DIE(),
		    {message => $msg, proto => $proto, program_error => 1},
		    ref($proto) || $proto, $1, $2);
	}
	1;
    } || warn($@);
    $_IN_HANDLE_DIE--;
}

# _new proto attrs package file line : Bivio::Die
#
# Creates a new Bivio::Die from the specified parameters which all must
# be "valid".  Sets $_CURRENT_SELF if $_CURRENT_SELF is undef.
#
sub _new {
    my($proto, $code, $attrs, $package, $file, $line) = @_;
    my($self) = Bivio::Collection::Attributes::new($proto, {
	next => undef,
	code => $code,
	attrs => $attrs,
	package => $package,
	file => $file,
	line => $line});
    if ($_CURRENT_SELF) {
	my($curr, $next) = $_CURRENT_SELF;
	$curr = $next while $next = $curr->get('next');
	$curr->put('next' => $self);
    }
    else {
	$_CURRENT_SELF = $self;
    }
    &_trace($self) if $_TRACE;
    return $self;
}

# _new_from_core_die proto attrs package file line : Bivio::Die
#
# Called with the result of a CORE::die.  If $attrs->{message} is equal to the
# string form of any of the current die values, then return that value.
# Otherwise, create new Bivio::Die from the listed values.
#
sub _new_from_core_die {
    my($proto, $code, $attrs, $package, $file, $line) = @_;
    if ($_CURRENT_SELF) {
	my($msg) = $attrs->{message};
	for (my($curr) = $_CURRENT_SELF; $curr; $curr = $curr->get('next')) {
	    return $curr if $msg eq "$curr\n";
	}
    }
    return _new(@_);
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
