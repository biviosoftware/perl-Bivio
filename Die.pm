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
	my($proto, $die_msg) = @_;
    }
    Bivio::Die->get_last;
    $die->push_error($new);
    $die->get_errors;

=cut

use Bivio::UNIVERSAL;
@Bivio::Die::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::Die> manages per-instance/class handlers for C<die>.  When C<die> is
called, C<Bivio::Die> searches up the stack for calls to public
methods of instances and classes which can C<handle_die>.  The
C<handle_die> methods are called in LIFO order, i.e. the most recently
called to last.

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
use UNIVERSAL ();
use Bivio::IO::Config;
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_STACK_TRACE) = 0;
my($_LAST_SELF);
Bivio::IO::Config->register({
    'stack_trace' => $_STACK_TRACE,
});

=head1 FACTORIES

=cut

=for html <a name="catch"></a>

=head2 catch(sub code) : UNIVERSAL or undef

Installs a local C<$SIG{__DIE__}> handler, calls I<code>,
and returns the result of I<code>.  Callers must be able to
detect whether I<code> executed successfully.  I<code> should
therefore return something which is not undef if it executed
correctly.

The stack is unwound until this method is found.  Therefore, callers of
L<catch|"catch"> must take care to appear in the call stack I<after> the call to L<catch|"catch">, e.g.

    sub some_sub {
	my($self) = @_;
	Bivio::Die->catch(sub {
	     $self->actual_sub;
	});
    }
    sub actual_sub {
	my($self);
	... do the normal work ...
    }
    sub handle_die {
	my($self, $die) = @_;
	... process die ..
    }

If a call to C<handle_die> results in a C<die>, C<$@> will be
pushed on the list of errors.

=cut

sub catch {
    my($proto, $code) = @_;
    $_LAST_SELF = undef;
    local($SIG{__DIE__}) = sub {
	my($msg) = @_;
	$_STACK_TRACE && print STDERR Carp::longmess($msg);
	my($self) = &Bivio::UNIVERSAL::new($proto);
	$self->{$_PACKAGE} = {
	    'errors' => [$msg],
	};
	$_LAST_SELF = $self;
	&_handle_die($self);
    };
    if (wantarray) {
	my(@res);
	eval {
	    @res = &$code();
	    $_LAST_SELF = undef;
	};
	return @res;
    }
    else {
	my($res);
	eval {
	    $res = &$code();
	    $_LAST_SELF = undef;
	};
	return $res;
    }
}

=head1 METHODS

=cut

=for html <a name="clear_errors"></a>

=head2 clear_errors()

Removes all errors associated with this instance.

=cut

sub clear_errors {
    my($fields) = shift(@_)->{$_PACKAGE};
    $fields->{errors} = [];
    return;
}

=for html <a name="clear_last"></a>

=head2 static clear_last()

Clears state associated with L<get_last|"get_last">.

=cut

sub clear_last {
    # This breaks any circular references, so AGC can work
    defined($_LAST_SELF) && $_LAST_SELF->clear_errors;
    $_LAST_SELF = undef;
    return;
}

=for html <a name="get_errors"></a>

=head2 get_errors() : array_ref OR undef

Returns the current list of errors associated with this die, in
the order they occurred.  If there are no errors, returns C<undef>.

=cut

sub get_errors {
    my($fields) = shift(@_)->{$_PACKAGE};
    return @{$fields->{errors}} ? $fields->{errors} : undef;
}

=for html <a name="get_last"></a>

=head2 static get_last() : Bivio::Die or undef

Returns the last Die object to be created by L<catch|"catch">.
Returns C<undef> if the last L<catch|"catch"> returned successfully.

=cut

sub get_last {
    return $_LAST_SELF;
}

=for html <a name="handle_config"></a>

=head2 static handle_config(string class, hash cfg)

=over 4

=item stack_trace : boolean [false]

If true, will print a stack trace on L<die|"die">.

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_STACK_TRACE = $cfg->{stack_trace};
    return;
}

=for html <a name="push_error"></a>

=head2 push_error(UNIVERSAL error)

Add a new error to this die.  The meaning of I<error> is application
dependent.

=cut

sub push_error {
    my($self, $error) = @_;
    my($fields) = $self->{$_PACKAGE};
    defined($error) || die('missing argument or undef');
    push(@{$fields->{errors}}, $error);
    return;
}


#=PRIVATE METHODS

# Process a die request
sub _handle_die {
    my($self) = @_;
    my($i) = 0;
    my(@a);
    my($prev_proto) = '';
    while (do { { package DB; @a = caller($i++) } } ) {
	my($sub, $has_args) = @a[3,4];
	# Only call if argument is to a public method in a module
	defined($sub) && $sub =~ /::[a-z]\w+$/ && $has_args || next;
	$sub eq "${_PACKAGE}::catch" && next;
	my($proto) = $DB::args[0];
	UNIVERSAL::can($proto, 'handle_die') || next;
	# Don't call twice if in same "entry" into module
	$prev_proto ne $proto || next;
	$prev_proto = $proto;
	&_trace("calling ", ref($proto) || $proto, "->handle_die") if $_TRACE;
	eval {
	    $proto->handle_die($self);
	    1;
	} && next;
	&_trace($proto, "->handle_die: ", $@) if $_TRACE;
	$self->push_error($@);
    }
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
