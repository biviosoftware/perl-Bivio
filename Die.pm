# Copyright (c) 1999-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Die;
use strict;
use base 'Bivio::Collection::Attributes';
use Bivio::DieCode;
use Bivio::IO::Alert;
use Bivio::IO::Config;
use Bivio::IO::Trace;
use Carp ();

# C<Bivio::Die> manages per-instance/class handlers for C<die>.  When C<die> is
# called, C<Bivio::Die> searches up the stack for calls to public
# methods of instances and classes which can C<handle_die>.  The
# C<handle_die> methods are called in LIFO order, i.e. the most recently
# called to current.
#
# C<handle_die> methods may change the die code, but they should not
# call L<die|"die"> or C<CORE::die>.  This will result in an error state.
#
# Classes do not register with this module.  Instead, the method
# L<catch|"catch"> which sets C<$SIG{__DIE__}> locally is used.
#
# This module is policy neutral with respect to error handling.  It
# holds errors and it is the responsibility of the L<catch|"catch"> caller
# and C<handle_die> implementers to do something about the errors.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
our($_CURRENT_SELF);
our($_IN_CATCH);
our($_IN_HANDLE_DIE);
our($_CATCH_QUIETLY);
my($_STACK_TRACE) = 0;
my($_STACK_TRACE_ERROR) = 0;
my($_STACK_TRACE_SEPARATOR) = join('', '      -'x10, "\n");
my($_A) = 'Bivio::IO::Alert';
Bivio::IO::Config->register({
    'stack_trace' => $_STACK_TRACE,
    'stack_trace_error' => $_STACK_TRACE_ERROR,
    'stack_trace_separator' => $_STACK_TRACE_SEPARATOR,
});

sub as_string {
    # (self) : string
    # Returns Die object and all its subsequent errors as a string.
    my($self) = @_;
    my($res) = '';
    for (my($curr) = $self; $curr; $curr = $curr->unsafe_get('next')) {
	if ($curr->is_destroyed) {
	    $res .= "$curr->is_destroyed returned true unexpectedly";
	    next;
	}
	$res .= "$curr->as_string: $@\n"
	    unless eval {
		my($c, $a, $p, $f, $l) = $curr->unsafe_get(
		    'code', 'attrs', 'package', 'file', 'line');
		$res .= $_A->format($p, $f, $l, undef,
			_as_string_args($c, $a));
		chomp($res);
		1;
	    };
    }
    return $res;
}

sub catch {
    # (self, any) : Bivio.Die
    # (self, any, ref) : any
    # Installs a local C<$SIG{__DIE__}> handler, calls I<code>.
    # If I<code> succeeds without error, C<undef> is returned.
    # Otherwise, a C<Bivio::Die> object is returned.  These may
    # be chained, i.e. if there is a C<die> within a C<die>,
    # the first instance will be linked to the second and can
    # be retrieved with L<get_next|"get_next">.
    #
    # The stack is unwound until this method (catch) is found and then we unwind
    # one more to allow the caller of catch to have a C<handle_die> routine.
    #
    # If a call to C<handle_die> results in a C<die>, a new die
    # object will be created and chained on to the current die.
    #
    # You may not call catch from within a die handler, because
    # C<$SIG{__DIE__}> is specifically disabled.
    #
    # If I<code> is a string or string_ref, will be evaled in the caller's package.
    #
    # If I<die> is a ref (scalar or ref), the return value of this method
    # will be the return value (with appropriate wantarray context) of I<code>.
    # I<die> will be C<undef> if I<code> succeeded.
    # If I<code> threw a Die, I<die> will contain that value
    # and the return value will be C<undef> or an empty list.
    #
    # $_ is localized in this call.  Do not assume it will be modified by I<code>.
    my($proto, $code, $die) = @_;
    local($_CURRENT_SELF);
    local($_IN_CATCH) = 1;
    local($SIG{__DIE__}) = sub {
	my($msg) = @_;
	_handle_die(_new_from_core_die($proto, Bivio::DieCode->DIE,
		{(message => $msg eq "\n" ? $_A->get_last_warning
		    : $msg),
		    program_error => 1,
		},
		(caller)[0,1,2],
		Carp::longmess("die"),
	       ));
	return;
    };

    # Call in appropriate context and return appropriate result
    unless (ref($die) =~ /^SCALAR$|^REF$/) {
	# Normal case: no $die arg
	_eval($code);
	return _catch_done($proto);
    }

    if (wantarray) {
	# Return array with $die
	my(@res) = _eval($code);
	$$die = _catch_done($proto);
	return $$die ? () : @res;
    }

    # Return scalar with $die
    my $res = _eval($code);
    $$die = _catch_done($proto);
    return $$die ? undef : $res;
}

sub catch_quietly {
    local($_CATCH_QUIETLY) = 1;
    return shift->catch(@_);
}

sub destroy {
    # (self) : undef
    # Destroys self and removes from the current chain.  The initial error is not
    # actually destroyed, but is set in L<is_destroyed|"is_destroyed"> state.  This
    # allows L<catch|"catch"> to know there is an error while also knowing all errors
    # were handled.  I<code> is set to C<undef> which is the flag that this
    # instance was destroyed.
    #
    # If self is not part of the current catch, then it is simply set to destroyed
    # and its next link is left untouched.
    my($self) = @_;
    $self->put('code' => undef);

    # No current chain
    return unless $_CURRENT_SELF;

    # Head of chain
    if ($_CURRENT_SELF eq $self) {
	my($next) = $_CURRENT_SELF->unsafe_get('next');
	$_CURRENT_SELF->put('next', undef);
	$_CURRENT_SELF = $next;
	return;
    }

    # Somewhere in the chain?
    my($curr, $next) = $_CURRENT_SELF;
    while ($next = $curr->unsafe_get('next')) {
	next unless $next eq $self;
	$curr->put('next', $next->unsafe_get('next'));
	$self->put('next' => undef);
	last;
    }

    # Not part of "current" chain.  Don't update next link.
    return;
}

sub die {
    my($proto) = shift;
    my($cc) = $_A->is_calling_context($_[0])
	? shift : $_A->calling_context;
    $proto->throw(
        $cc,
	Bivio::DieCode->DIE, {
	    message => $_A->format_args(@_),
	    program_error => 1,
	},
	Carp::longmess('Bivio::Die::die'),
    );
    # DOES NOT RETURN
}

sub eval {
    # (proto, code_ref) : any
    # (proto, string) : any
    # (proto, string_ref) : any
    # Calls eval on I<code>, but turns off any handle_die processing.  This should be
    # used everywhere in place of a normal eval.  Returns the result of I<sub>.
    #
    # If I<code> is a string or string_ref, will be evaled in the caller's package.
    #
    # NOTE: Warnings are not suppressed during code execution.
    #
    # $_ is localized in this call.  Do not assume it will be modified by I<code>.
    #
    # Returns C<undef> in the event of an error, just like C<CORE::eval>.
    my(undef, $code) = @_;
    local($SIG{__DIE__});
    local($_CURRENT_SELF) = $_CURRENT_SELF;
    return _eval($code);
}

sub eval_or_die {
    # (proto, any) : any
    # Calls L<catch|"catch"> preserving calling context (using wantarray).  If the
    # operation fails, rethrows the die.  Otherwise, returns the result as in
    # L<catch|"catch"> with preseved call context.
    #
    # $_ is localized in this call.  Do not assume it will be modified by I<code>.
    my($proto, $code) = @_;
    my($die);
    if (wantarray) {
	my(@res) = $proto->catch($code, \$die);
	return @res unless $die;
    }
    else {
	my $res = $proto->catch($code, \$die);
	return $res unless $die;
    }
    $die->throw;
    # DOES NOT RETURN
}

sub handle_config {
    # (proto, string, hash) : undef
    # stack_trace : boolean [false]
    #
    # If true, will print a stack trace on L<throw|"throw">.
    #
    # stack_trace_error : boolean [false]
    #
    # If true, will print a stack trace on a L<throw|"throw"> which contains a
    # I<program_error> attribute which evaluates to I<true>.  I<program_error> is
    # set automatically for C<CORE::die> calls and other internal errors in
    # handling L<throw|"throw"> calls, e.g. die within die.
    my(undef, $cfg) = @_;
    $_STACK_TRACE = $cfg->{stack_trace} ? 1 : 0;
    $_STACK_TRACE_ERROR = $cfg->{stack_trace_error} ? 1 : 0;
    $_STACK_TRACE_ERROR = 0 if $_STACK_TRACE;
    $_STACK_TRACE_SEPARATOR = $cfg->{stack_trace_separator};
    return;
}

sub is_destroyed {
    # (self) : boolean
    # Returns true if the instance was destroyed.
    return !shift->unsafe_get('code');
}

sub set_code {
    # (self, Bivio.DieCode, string, any, ...) : undef
    # Change the I<code> associated with I<self> and set new attributes.
    my($self, $code, @new_attrs) = @_;
    my($attrs) = $self->unsafe_get('attrs');
    $self->put(code => _check_code($code, $attrs));
    %$attrs = (%$attrs, @new_attrs) if @new_attrs;
    return;
}

sub throw {
    # Any of the parameters may be undef. Package and line will be filled in by this
    # module.  If you'd like to implement a module specific die, you might:
    #
    #     sub throw_die {
    # 	my($self, $code, $msg) = @_;
    # 	Bivio::Die->throw(Bivio::DieCode->unsafe_from_any($code),
    # 		{msg => $msg, object => $self}, caller);
    #     }
    #
    # C<caller> will be called in an array context and return the appropriate
    # attributes about the caller in the right order.  Note that
    # L<Bivio::Type::Enum::unsafe_from_any|Bivio::Type::Enum/"unsafe_from_any">
    # returns C<undef> if $code isn't found, so it is entirely safe.
    #
    # If I<code> is C<undef>, it will be set to C<Bivio::DieCode::UNKNOWN>.
    # If I<code> is a string, it will be converted to a L<Bivio::DieCode>
    # if possible.
    #
    # If I<attrs> is C<undef>, it will be set to the empty hash.
    # If I<attrs> is a not a reference, it will be set to C<{message => $attrs}>.
    # If I<attrs> is not a hash, it will be set to C<{attrs => $attrs}>.
    #
    # In the second form, I<self> is "rethrown".
    my($proto) = shift;
    local($_CURRENT_SELF)
	unless $_IN_CATCH;
    if (ref($proto)) {
	# Rethrow of an existing die.  If inside a catch, set as current
	# and pass by name.
	$_CURRENT_SELF = $proto;
	CORE::die("$proto\n")
	    if $_IN_CATCH;
	# Not in a catch, so must call handle_die explicitly
	_handle_die($proto);
	# _handle_die returns, but user called die.  So need to
	# throw a bogus exception.
	CORE::die(
	    $proto->unsafe_get('throw_quietly')
	    ? "\n" : $proto->as_string."\n",
	);
    }
    my($cc) = shift
	if $_A->is_calling_context($_[0]);
    my($code, $attrs) = (shift, shift);
    my($package, $file, $line) = $cc ? $cc->get_top_package_file_line
	: (shift, shift, shift);
    my($self) = _new_from_throw(
	$proto,
	$code,
	$attrs,
	$package, $file, $line,
	shift || Carp::longmess('Bivio::Die::throw'),
    );
    CORE::die($_IN_CATCH ? "$self\n" : $self->as_string."\n");
    # DOES NOT RETURN
}

sub throw_die {
    # (proto, Bivio.DieCode, hash_ref, string, string, int) : undef
    # Calls L<throw|"throw">.  This allows clean implementations of
    # C<throw_die> in other modules.  You can pass C<Bivio::Die> as a
    # C<$die> object (see e.g. L<Bivio::SQL::Connection|Bivio::SQL::Connection>).
    my($proto, $code, $attrs, $package, $file, $line) = @_;
    shift->throw($code, $attrs, $package, $file, $line,
        Carp::longmess('Bivio::Die::throw_die'));
    # DOES NOT RETURN
}

sub throw_or_die {
    # (proto, any, hash_ref, string, string, int) : undef
    # (proto, string, ...) : undef
    # Calls L<throw|"throw"> if I<code> is a Bivio::DieCode name or reference.
    # Otherwise, calls L<die|"die">.
    my($proto) = shift;
    my($cc) = $_A->is_calling_context($_[0]) ? shift : $_A->calling_context;
    my($code) = @_;
    my($m) = UNIVERSAL::isa($code, 'Bivio::DieCode')
	|| Bivio::DieCode->is_valid_name($code)
	&& Bivio::DieCode->unsafe_from_name($code)
	? 'throw' : 'die';
    $proto->$m($cc, @_);
    # DOES NOT RETURN
}

sub throw_quietly {
    # (proto, Bivio.DieCode, hash_ref, string, string, int) : undef
    # (self) : undef
    # Same as L<throw|"throw">, but no stack trace or error message is output.
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

sub _as_string_args {
    # (Bivio.DieCode, hash_ref) : any
    # Tries to create an economical message.  Leaves formatting up
    # to $_A (see as_string).
    my($code, $attrs) = @_;
    return [$code, ': ', $attrs->{message}]
	if $attrs->{message}
	&& int(keys(%$attrs)) <= 1 + ($attrs->{program_error} ? 1 : 0);
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

sub _caller {
    my($i) = 0;
    # Avoid insanity
    0 while caller(++$i) eq __PACKAGE__ && $i < 1_000_000;
    return [caller($i)];
}

sub _catch_done {
    # () : Bivio.Die
    # Returns $_CURRENT_SELF if got an error ($@) or undef.  Handles
    # case where _eval() fails because of a syntax error.
    # Cleans up catch state.
    my($proto) = @_;
    return $_CURRENT_SELF
        || ($@ ? _new_from_eval_syntax_error($proto) : undef);
}

sub _check_code {
    # (any, hash_ref) : Bivio.DieCode
    # Validates code and sets attributes to error state if invalid.
    my($code, $attrs) = @_;
    unless (defined($code)) {
	$attrs->{program_error} = 1;
	return Bivio::DieCode->UNKNOWN;
    }
    return $code
	if UNIVERSAL::isa($code, 'Bivio::DieCode');
    my($c) = Bivio::DieCode->unsafe_from_any($code);
    return $c
	if $c;
    %$attrs = (code => $code, attrs => {%$attrs}, program_error => 1);
    return Bivio::DieCode->INVALID_DIE_CODE;
}

sub _eval {
    # (any) : any
    # Evaluates code (maintaining return context)
    my($code) = @_;
    local($_);
    # Don't put in newline, because would change line numbering
    my($caller) = _caller()->[0];
    unless (ref($code) eq 'CODE') {
	my($c) = ref($code) ? $$code : $code;
	return
	    unless $code = eval(qq{package $caller; sub {$c}});
    }
    return eval(qq{package $caller; \$code->();});
}

sub _handle_die {
    # (self) : undef
    # Called from within $SIG{__DIE__} inside catch.  $_CURRENT_SELF is
    # already created.  Calls the die handlers sequentially.  If errors
    # occur, chains them on to $_CURRENT_SELF by calling _new_from_core_die.
    local($_IN_HANDLE_DIE) = 1;
    eval {
	local($SIG{__DIE__});
	my($self) = @_;
	_print_stack($self)
	    if $_TRACE
	    || $_STACK_TRACE
	    || $_STACK_TRACE_ERROR
	    && ($self->unsafe_get('attrs') || {program_error => 1})
		->{program_error};
	my($i) = 0;
	my(@a);
	my($prev_proto) = '';
	my($stop) = -1;
	my(%already_seen);
	# Iterate until just one routine after catch
	while ($stop <= 0 && do { { package DB; @a = caller($i++) } } ) {
	    # Only start incrementing stop when "catch" is seen
	    $stop++ if $stop >= 0;
	    my($sub, $has_args) = @a[3,4];
	    # Only call if argument is to a public method in a module
	    next unless defined($sub) && $sub =~ /::[a-z]\w+$/ && $has_args;
	    if ($sub eq __PACKAGE__.'::catch') {
		# This gives us one more loop iteration
		$stop++;
		next;
	    }

	    # Does this sub's argument (self or proto) implement handle_die?
	    my($proto) = $DB::args[0];
	    next unless $proto && UNIVERSAL::can($proto, 'handle_die');

	    # Don't call twice if in same "entry" into self or proto.
	    # OK to call multiple times on instances of same class.
	    next if $already_seen{$proto}++;

	    # Continue if successful eval
	    next if eval {
		_trace("calling ", ref($proto) || $proto, "->handle_die")
		    if $_TRACE;
		$proto->handle_die($self);
		1;
	    };

	    # Unsuccessful eval, chain the error.
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
		_new_from_core_die(
		    $self,
		    Bivio::DieCode->DIE_WITHIN_HANDLE_DIE,
		    {
			message => $msg,
			proto => $proto,
			program_error => 1,
			file => $1,
			line => $2,
		    },
		    ref($proto) || $proto, $1, $2,
		    Carp::longmess('Bivio::Die::_handle_die'),
		);
	    }
	}
	1;
    } || warn($@);
    return;
}

sub _new {
    # (proto, Bivio.DieCode, hash_ref, string, string, string, string) : Bivio.Die
    # Creates a new Bivio::Die from the specified parameters which all must
    # be "valid".  Sets $_CURRENT_SELF if $_CURRENT_SELF is undef.
    my($proto, $code, $attrs, $package, $file, $line, $stack) = @_;
    my($self) = $proto->new({
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
	$curr = $next while $next = $curr->unsafe_get('next');
	$curr->put('next' => $self);
    }
    else {
	$_CURRENT_SELF = $self;
    }
    _trace($self) if $_TRACE;
    # After trace, so not too verbose
    $self->put(stack => $stack || '');
    _print_stack($self) if $_TRACE || $_STACK_TRACE;
    return $self;
}

sub _new_from_core_die {
    # (proto, hash_ref, string, string, string, string) : Bivio.Die
    # Called with the result of a CORE::die.  If $attrs->{message} is equal to the
    # string form of any of the current die values, then return that value.
    # Otherwise, create new Bivio::Die from the listed values.
    my($proto, $code, $attrs, $package, $file, $line, $stack) = @_;
    if ($_CURRENT_SELF) {
	my($msg) = $attrs->{message};
	for (my($curr) = $_CURRENT_SELF; $curr; $curr = $curr->unsafe_get('next')) {
	    next unless $msg eq "$curr\n";
	    return $curr;
	}
    }

    return _new($proto, $code, $attrs, $package, $file, $line, $stack);
}

sub _new_from_eval_syntax_error {
    # (proto) : Bivio.Die
    # When eval gets a syntax error, we don't get a call to "die".  Don't
    # ask me why she swallowed the fly....
    # 
    # We create a new Die and trace stack if necessary.
    my($proto) = @_;
    my($self) = _new_from_throw($proto, Bivio::DieCode->DIE,
	    {message => $@, program_error => 1},
	    undef, undef, undef, Carp::longmess($@));
    _print_stack($self)
	if $_TRACE || $_STACK_TRACE || $_STACK_TRACE_ERROR
	&& ($self->unsafe_get('attrs') || {program_error => 1})
	->{program_error};
    return $self;
}

sub _new_from_throw {
    # (proto, any, hash_ref, string, string, string, string) : Bivio.Die
    # Sets attrs, file, line, etc.
    my($proto, $code, $attrs, $package, $file, $line, $stack) = @_;
    $attrs = defined($attrs) ? !ref($attrs) ? {message => $attrs}
	:  {attrs => $attrs} : {}
        unless ref($attrs) eq 'HASH';
    my($caller) = _caller();
    return _new(
	$proto,
	_check_code($code, $attrs),
	$attrs,
	$package || $caller->[0],
	$file || $caller->[1],
	$line || $caller->[2],
	$stack,
    );
}

sub _print_stack {
    # (self) : undef
    # Prints the stack trace.
    my($self) = @_;
    my($sp, $tq) = $self->unsafe_get('stack_printed', 'throw_quietly');
    return
	if $sp;
    return
	unless $_TRACE || $_STACK_TRACE || !$tq && !$_CATCH_QUIETLY;
    $_A->print_literally(
	$self->as_string, "\n",
	$self->unsafe_get('stack'),
	$_STACK_TRACE_SEPARATOR,
    );
    $self->put(stack_printed => 1);
    return;
}

1;
