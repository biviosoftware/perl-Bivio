# Copyright (c) 1999,2000,2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Die;
use strict;
$Bivio::Die::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);
$_ = $Bivio::Die::VERSION;

=head1 NAME

Bivio::Die - manages exceptions with catch/die_handler and eval wrapper

=head1 SYNOPSIS

    use Bivio::Die;

=cut

use Bivio::Collection::Attributes;
@Bivio::Die::ISA = ('Bivio::Collection::Attributes');

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

=head2 catch(code_ref code) : Bivio::Die or undef

=head2 catch(string code) : Bivio::Die or undef

Installs a local C<$SIG{__DIE__}> handler, calls I<code>.
If I<code> succeeds without error, C<undef> is returned.
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
    my($proto, $code) = @_;
    Bivio::Die->die(Bivio::DieCode::CATCH_WITHIN_DIE(),
	    {code => $code, program_error => 1}, (caller)[0], (caller)[2])
		if $_IN_HANDLE_DIE;
    $_IN_CATCH++;
    local($SIG{__DIE__}) = sub {
	my($msg) = @_;
	_handle_die(_new_from_core_die($proto, Bivio::DieCode::DIE(),
		{(message => $msg eq "\n" ? Bivio::IO::Alert->get_last_warning
		    : $msg),
		    program_error => 1,
		},
		(caller)[0,1,2],
		Carp::longmess("die"),
	       ));
	return;
    };
    my($self) = (ref($code) ? eval {&$code(); 1} : eval($code.'; 1'))
	    ? undef : $_CURRENT_SELF;
    $_CURRENT_SELF = undef;
    $_IN_CATCH--;
    return $self;
}

=head1 METHODS

=cut

=for html <a name="as_string"></a>

=head2 as_string() : string

Returns Die object and all its subsequent errors as a string.

=cut

sub as_string {
    my($self) = @_;
    my($res) = '';
    for (my($curr) = $self; $curr; $curr = $curr->get('next')) {
	eval {
	    return 0 if $curr->is_destroyed;
	    my($c, $a, $p, $f, $l) = $curr->get(
		'code', 'attrs', 'package', 'file', 'line');
	    $res .= Bivio::IO::Alert->format($p, $f, $l, undef,
		    _as_string_args($c, $a));
	    chomp($res);
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

=head2 static die(string arg1, ...)

Wrapper for L<throw|"throw">.  Takes similar arguments to CORE::die.

=cut

sub die {
    my($proto) = shift;
    $proto->throw(Bivio::DieCode::DIE(), {
	message => Bivio::IO::Alert->format_args(@_),
	program_error => 1,
    },
	    (caller)[0,1,2],
	    Carp::longmess('Bivio::Die::die'),
	   );
    # DOES NOT RETURN
}

=for html <a name="eval"></a>

=head2 static eval(code_ref sub) : any

=head2 static eval(string code) : any

Calls eval on I<code>, but turns off any handle_die processing.  This should be
used everyhwere in place of a normal eval.  Returns the result of I<sub>.

=cut

sub eval {
    my($self, $code) = @_;
    local($SIG{__DIE__});
    return ref($code) ? eval {&$code();} : eval($code);
}

=for html <a name="eval_or_die"></a>

=head2 static eval_or_die(any code) : any

Calls L<eval|"eval"> and dies if it fails.

=cut

sub eval_or_die {
    my($self) = shift;
    my($res) = $self->eval(@_);
    $self->throw_die('DIE', {
	message => $@,
	program_error => 1,
    }) if $@;
    return $res;
}

=for html <a name="handle_config"></a>

=head2 static handle_config(string class, hash cfg)

=over 4

=item stack_trace : boolean [false]

If true, will print a stack trace on L<throw|"throw">.

=item stack_trace_error : boolean [false]

If true, will print a stack trace on a L<throw|"throw"> which contains a
I<program_error> attribute which evaluates to I<true>.  I<program_error> is
set automatically for C<CORE::die> calls and other internal errors in
handling L<throw|"throw"> calls, e.g. die within die.

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_STACK_TRACE = $cfg->{stack_trace} ? 1 : 0;
    $_STACK_TRACE_ERROR = $cfg->{stack_trace_error} ? 1 : 0;
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

=for html <a name="set_code"></a>

=head2 set_code(Bivio::Type::Enum code, string new_attr, any new_attr_value, ...)

Change the I<code> associated with I<self> and set new attributes.

=cut

sub set_code {
    my($self, $code, @new_attrs) = @_;
    my($attrs) = $self->get('attrs');
    $self->put(code => _check_code($code, $attrs));
    %$attrs = (%$attrs, @new_attrs) if @new_attrs;
    return;
}

=for html <a name="throw"></a>

=head2 static throw(Bivio::Type::Enum code, hash_ref attrs, string package, string file, int line)

=head2 throw()

Any of the parameters may be undef. Package and line will be filled in by this
module.  If you'd like to implement a module specific die, you might:

    sub throw_die {
	my($self, $code, $msg) = @_;
	Bivio::Die->throw(My::Package::DieCode->from_any($code),
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

In the second form, I<self> is "rethrown".

=cut

sub throw {
    my($proto, $code, $attrs, $package, $file, $line, $stack) = @_;
    if (ref($proto)) {
	# Rethrow of an existing die.  If inside a catch, set as current
	# and pass by name.
	$_CURRENT_SELF = $proto;
	CORE::die("$proto\n") if $_IN_CATCH;
	# Not in a catch, so must call handle_die explicitly
	_handle_die($proto);
	# _handle_die returns, but user called die.  So need to
	# throw a bogus exception.
	CORE::die($proto->unsafe_get('throw_quietly')
		? "\n" : $proto->as_string."\n");
    }
    my($self) = _new_from_throw($proto, $code, $attrs, $package, $file, $line,
	    $stack || Carp::longmess('Bivio::Die::throw'));
    CORE::die($_IN_CATCH ? "$self\n" : $self->as_string."\n");
}

=for html <a name="throw_die"></a>

=head2 static throw_die(Bivio::Type::Enum code, hash_ref attrs, string package, string file, int line)

Calls L<throw|"throw">.  This allows clean implementations of
C<throw_die> in other modules.  You can pass C<Bivio::Die> as a
C<$die> object (see e.g. L<Bivio::SQL::Connection|Bivio::SQL::Connection>).

=cut

sub throw_die {
    my($proto, $code, $attrs, $package, $file, $line) = @_;
    shift->throw($code, $attrs, $package, $file, $line,
	    Carp::longmess('Bivio::Die::throw_die'));
    # DOES NOT RETURN
}

=for html <a name="throw_quietly"></a>

=head2 static throw_quietly(Bivio::Type::Enum code, hash_ref attrs, string package, string file, int line)

=head2 throw_quietly()

Same as L<throw|"throw">, but no stack trace or error message is output.

=cut

sub throw_quietly {
    my($proto, $code, $attrs, $package, $file, $line) = @_;
    if (ref($proto)) {
	$proto->put(throw_quietly => 1);
	$proto->throw($proto, $code, $attrs, $package, $file, $line,
		Carp::longmess('Bivio::Die::throw_quietly'));
	# DOES NOT RETURN
    }
    my($self) = _new_from_throw($proto, $code, $attrs, $package, $file, $line,
	    Carp::longmess('Bivio::Die::throw_quietly'));
    # Be quiet
    CORE::die($_IN_CATCH ? "$self\n" : "\n");
    # DOES NOT RETURN
}

#=PRIVATE METHODS

# _as_string_args(Bivio::DieCode code, hash_ref attrs) : any
#
# Tries to create an economical message.  Leaves formatting up
# to Bivio::IO::Alert (see as_string).
#
sub _as_string_args {
    my($code, $attrs) = @_;
    return [$code, ': ', $attrs->{message}]
	    if $attrs->{message}
		    && int(keys(%$attrs))
			    <= 1 + ($attrs->{program_error} ? 1 : 0);
    my($msg) = [$code];
    if (%$attrs) {
	# Don't just "join", because we want Alert to call
	# as->string if appropriate.
	push(@$msg, ': ', map {
	    ($_, '=>', $attrs->{$_}, ' ');
	} sort keys %$attrs);
	pop(@$msg);
    }
    return $msg;
}

# _check_code(any code, hash_ref attrs) : Bivio::Type::Enum
#
# Validates code and sets attributes to error state if invalid.
#
sub _check_code {
    my($code, $attrs) = @_;
    if (defined($code)) {
	unless (ref($code) && UNIVERSAL::isa($code, 'Bivio::Type::Enum')) {
	    if (my $c = Bivio::DieCode->unsafe_from_any($code)) {
		$code = $c;
	    } else {
		my($a) = {%$attrs};
		%$attrs = (code => $code, attrs => $a, program_error => 1);
		$code = Bivio::DieCode::INVALID_DIE_CODE();
	    }
	}
    }
    else {
	$code = Bivio::DieCode::UNKNOWN();
	$attrs->{program_error} = 1;
    }
    return $code;
}

# _handle_die(self)
#
# Called from within $SIG{__DIE__} inside catch.  $_CURRENT_SELF is
# already created.  Calls the die handlers sequentially.  If errors
# occur, chains them on to $_CURRENT_SELF by calling _new_from_core_die.
#
sub _handle_die {
    $_IN_HANDLE_DIE++;
    eval {
	local($SIG{__DIE__});
	my($self) = @_;
	if ($_STACK_TRACE_ERROR) {
	    my($a) = $self->get('attrs');
	    _print_stack($self) if $a->{program_error};
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
	    $proto && UNIVERSAL::can($proto, 'handle_die') || next;
	    # Don't call twice if in same "entry" into module
	    $prev_proto ne $proto || next;
	    $prev_proto = $proto;
	    eval {
		_trace("calling ", ref($proto) || $proto, "->handle_die")
		    if $_TRACE;
		$proto->handle_die($self);
		1;
	    } && next;
	    my($msg) = $@;
	    # If not rethrow of an existing error?
	    if ($msg eq "$self\n") {
		# In this case, we don't want as_string
		_trace("$self: self rethrown") if $_TRACE;
	    }
	    elsif ($msg eq "$_CURRENT_SELF\n") {
		# In this case, we don't want as_string
		_trace("$_CURRENT_SELF: older die rethrown") if $_TRACE;
		$self = $_CURRENT_SELF;
	    }
	    else {
		eval {
		    _trace($proto, "->handle_die: ", $msg) if $_TRACE;
		};
		$msg =~ / at (\S+|\(eval \d+\)) line (\d+)\.\n$/;
		_new_from_core_die($self,
			Bivio::DieCode::DIE_WITHIN_HANDLE_DIE(),
			{message => $msg, proto => $proto, program_error => 1},
			ref($proto) || $proto, $1, $2,
			Carp::longmess('Bivio::Die::_handle_die'));
	    }
	}
	1;
    } || warn($@);
    $_IN_HANDLE_DIE--;
}

# _new(proto, Bivio::Type::Enum code, hash_ref attrs, string package, string file, string line, string stack) : Bivio::Die
#
# Creates a new Bivio::Die from the specified parameters which all must
# be "valid".  Sets $_CURRENT_SELF if $_CURRENT_SELF is undef.
#
sub _new {
    my($proto, $code, $attrs, $package, $file, $line, $stack) = @_;
    my($self) = Bivio::Collection::Attributes::new($proto, {
	next => undef,
	code => $code,
	attrs => $attrs,
	package => $package,
	file => $file,
	line => $line,
    });
    # FRAGILE
    $self->put(throw_quietly => 1) if (caller(2))[3] =~ /throw_quietly/;
    if ($_CURRENT_SELF) {
	my($curr, $next) = $_CURRENT_SELF;
	$curr = $next while $next = $curr->get('next');
	$curr->put('next' => $self);
    }
    else {
	$_CURRENT_SELF = $self;
    }
    _trace($self) if $_TRACE;
    # After trace, so not too verbose
    $self->put(stack => $stack);
    _print_stack($self) if $_STACK_TRACE;
    return $self;
}

# _new_from_core_die(proto, hash_ref attrs, string package, string file, string line, string stack) : Bivio::Die
#
# Called with the result of a CORE::die.  If $attrs->{message} is equal to the
# string form of any of the current die values, then return that value.
# Otherwise, create new Bivio::Die from the listed values.
#
sub _new_from_core_die {
    my($proto, $code, $attrs, $package, $file, $line, $stack) = @_;
    if ($_CURRENT_SELF) {
	my($msg) = $attrs->{message};
	for (my($curr) = $_CURRENT_SELF; $curr; $curr = $curr->get('next')) {
	    next unless $msg eq "$curr\n";
	    return $curr;
	}
    }

    return _new($proto, $code, $attrs, $package, $file, $line, $stack);
}

# _new_from_throw(proto, any code, hash_ref attrs, string package, string file, string line, string stack) : Bivio::Die
#
# Sets attrs, file, line, etc.
#
sub _new_from_throw {
    my($proto, $code, $attrs, $package, $file, $line, $stack) = @_;
    my($i) = 0;
    $i++ while caller($i) eq __PACKAGE__;
    $package ||= (caller($i))[0];
    $file ||= (caller($i))[1];
    $line ||= (caller($i))[2];
    unless (ref($attrs) eq 'HASH') {
	$attrs = defined($attrs)
		? !ref($attrs) ? {message => $attrs}
			:  {attrs => $attrs} : {};
    }
    $code = _check_code($code, $attrs);
    return _new($proto, $code, $attrs, $package, $file, $line, $stack);
}

# _print_stack(self)
#
# Prints the stack trace.
#
sub _print_stack {
    my($self) = @_;
    my($sp, $tq) = $self->unsafe_get('stack_printed', 'throw_quietly');
    return if $sp || $tq;
    Bivio::IO::Alert->print_literally($self->as_string."\n");
    Bivio::IO::Alert->print_literally($self->get('stack'));
    $self->put(stack_printed => 1);
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999,2000,2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
