# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::FormContext;
use strict;
$Bivio::Biz::FormContext::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::FormContext - initializes, parses, and stringifies FormModel context

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::FormContext;

=cut

=head1 EXTENDS

L<Bivio::Collection::Attributes>

=cut

use Bivio::Collection::Attributes;
@Bivio::Biz::FormContext::ISA = ('Bivio::Collection::Attributes');

=head1 DESCRIPTION

C<Bivio::Biz::FormContext> is a utility module for
L<Bivio::Biz::FormModel|Bivio::Biz::FormModel>.  It initializes,
parses, and stringifies a form's context.  FormModel sets the
context from the form state in
L<Bivio::Biz::FormModel::get_context_from_request|Bivio::Biz::FormModel/"get_context_from_request">.
The two classes are therefore very tightly coupled.

A form context is a Bivio::Collection::Attributes which tell the
FormModel how to "unwind", i.e. how to go back to what the user
was doing before the current form.  Contexts may be nested, which
adds to the complexity.

Since contexts can be nested, they can be long.  The stringified version is
"compact".  The structure is:

   <char><http-base64> "!" <char><http-base64> ...

The http-base64 encoding may contain a serialized hash, realm name, or
nested context.  See L<Bivio::MIME::Base64|Bivio::MIME::Base64> for
a description of http-base64.

=head1 ATTRIBUTES

=over 4

=item cancel_task : Bivio::Agent::TaskId

When the form's cancel button is hit, this task will be executed.
Defaults to I<unwind_task>.

=item form : hash_ref

The contents of the form to be unwound to.  These are the literal
string values, yet to be converted to perl types.

If defined, a server_redirect will be executed.
May be C<undef>.

=item form_context : hash_ref

The form to unwind to has as well.  See FormModel for handling.

=item path_info : string

Passed to client or server_redirect during unwind.
May be C<undef>.

=item query : hash_ref

Passed to client or server_redirect during unwind.
May be C<undef>.

=item realm : Bivio::Auth::Realm

Specifies the realm in which the I<unwind_task> or I<cancel_task> are
executed.  Is C<undef> for the GENERAL realm.

=item unwind_task : Bivio::Agent::TaskId

When the form's OK button is hit, this task will be executed.
Is always defined.

=back

=cut

#=IMPORTS
use Bivio::IO::Ref;
use Bivio::IO::Trace;
use Bivio::MIME::Base64;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my(%_CHAR_TO_KEY) = (
    "a" => 'unwind_task',
    "b" => 'cancel_task',
    "c" => 'realm',
    "d" => 'query',
    "e" => 'form',
    "f" => 'path_info',
    # Since this is a recursive component, make it last
    "z" => 'form_context',
);
my(%_KEY_TO_CHAR) = map {($_CHAR_TO_KEY{$_}, $_)} keys(%_CHAR_TO_KEY);
# Sorts alphabetically so form_context (z) is last
my(@_CHARS) = sort(keys(%_CHAR_TO_KEY));
my($_CHARS) = join('', @_CHARS);
# These two characters can be anything not in MIME::Base64
my($_SEPARATOR) = '!';
# This character shouldn't collide with anything in a form or query.
# Forms don't have binary data.
# Tightly coupled with $Bivio::SQL::ListQuery::_SEPARATOR.
my($_HASH_CHAR) = "\01";

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attrs) : Bivio::Biz::FormContext

Trace the output

=cut

sub new {
    my($self) = shift->SUPER::new(@_);
    _trace($self) if $_TRACE;
    return $self;
}

=head1 METHODS

=cut

=for html <a name="as_literal"></a>

=head2 as_literal(Bivio::Agent::Request req) : string

Returns the stringified version of I<self>.  I<req> is used to
gather state, e.g. default realm.

=cut

sub as_literal {
    my($self, $req) = @_;
    my($res) = '';
    my($attrs) = $self->internal_get;
    _trace($attrs) if $_TRACE;
    # The order is the same as @_CHARS.  nice for debugging
    _format_task(\$res, $attrs, 'unwind_task');
    # Don't format cancel, if it doesn't contain anything
    _format_task(\$res, $attrs, 'cancel_task')
	if defined($attrs->{cancel_task})
	    && $attrs->{cancel_task} != $attrs->{unwind_task};
    _format_realm(\$res, $attrs);
    _format_hash(\$res, $attrs, 'query');
    _format_hash(\$res, $attrs, 'form');
    _format_string(\$res, 'path_info', $attrs->{path_info});
    # Recurse nested context only if we aren't reentering same task
    _format_string(\$res, 'form_context',
	$attrs->{form_context}->as_literal($req))
	if $attrs->{form_context}
	    && $attrs->{form_context}->get('unwind_task')
		!= $attrs->{unwind_task};
    # Remove trailing separator
    chop($res);
    _trace($res) if $_TRACE;
    return $res;
}

=for html <a name="as_string"></a>

=head2 as_string() : string

Converted for debugging purposes.  Use L<as_literal|"as_literal"> for most
purposes.

=cut

sub as_string {
    my($self) = @_;
    return ref($self)
	? Bivio::IO::Ref->to_short_string($self->get_shallow_copy)
	: $self;
}

=for html <a name="new_empty"></a>

=head2 static new_empty(Bivio::Biz::FormModel model) : Bivio::Biz::FormContext

Returns the new_empty context for the current task and realm.

=cut

sub new_empty {
    my($proto, $model) = @_;
    my($req) = $model->get_request;
    my($realm) = $req->get('auth_realm');
    my($task) = $req->get('task');
    return $proto->new({
	unwind_task => $task->get('next'),
	cancel_task => $task->get('cancel'),
	form_model => $task->get('form_model'),

	# We can assume that the realm is the same.
	realm => $realm,

	# The following is unknown.  We don't know where we came from,
	# we only know where we are.
	query => undef,
	path_info => undef,
	form => undef,
	form_context => undef,
    });
}

=for html <a name="new_from_form"></a>

=head2 static new_from_form(Bivio::Biz::FormModel model, hash_ref form_fields, Bivio::Biz::FormContext calling_context, Bivio::Agent::Request req) : Bivio::Biz::FormContext

Returns a new object for the current I<form> and I<calling_context>.

=cut

sub new_from_form {
    my($proto, $model, $form_fields, $calling_context, $req) = @_;
    return $proto->new({
	form_model => ref($model) || undef,
	form => $form_fields,
	form_context => $calling_context,
	query => $req->unsafe_get('query'),
	path_info => $req->unsafe_get('path_info'),
	unwind_task => $req->unsafe_get('task_id'),
	cancel_task => $req->get('task')->unsafe_get('cancel'),
	realm => $req->get('auth_realm'),
    });
}

=for html <a name="new_from_literal"></a>

=head2 static new_from_literal(Bivio::Biz::FormModel model, string value) : Bivio::Biz::FormContext

Parses the form context from the query or the form.  Errors result in
a warning and L<new_empty|"new_empty"> returned.

=cut

sub new_from_literal {
    # $err is boolean_ref used during recursion, hence it isn't in the
    # documentation.
    my($proto, $model, $value, $err) = @_;

    _trace(ref($model), ' incoming: ', $value) if $_TRACE;
    # First iterate over the fields and decode the base64.
    my($c) = {};
    foreach my $item (split(/$_SEPARATOR/o, $value)) {
	my($which, $enc) = $item =~ /^([$_CHARS])(.*)$/o;

	unless ($which) {
	    # If the context is completely screwed up, then return initial.
	    $$err = 1 if $err;
	    return _parse_error($proto, $model, $item, $which,
		    'missing or invalid element');
	}

	$which = $_CHAR_TO_KEY{$which};
	$c->{$which} = Bivio::MIME::Base64->http_decode($enc);
	return _parse_error($proto, $model, $item, $which, 'http_decode error')
		unless defined($c->{$which});
    }

    # Parse the decoded fields and validate. unwind_task must be checked first,
    # because it may clear all the rest of the state
    unless (_parse_task($model, $c, 'unwind_task')) {
	$$err = 1 if $err;
	return _parse_error($proto, $model, undef, 'unwind_task',
		'missing or bad unwind_task');
    }

    _parse_task($model, $c, 'cancel_task');
    _parse_path_info($model, $c);
    _parse_hash($model, $c, 'form');
    _parse_hash($model, $c, 'query');
    _parse_realm($model, $c);

    if (defined($c->{form_context})) {
	my($sub_err);
	$c->{form_context} = $proto->new_from_literal(
	    $model, $c->{form_context}, \$sub_err);
	$c->{form_context} = undef
	    if $sub_err;
    }
    else {
	$c->{form_context} = undef;
    }

    $c->{form_model} = Bivio::Agent::Task->get_by_id($c->{unwind_task})
	->get('form_model');
    return $proto->new($c);
}

=for html <a name="return_redirect"></a>

=head2 return_redirect(string which, Bivio::Agent::Request req)

Redirects back to the task contained in the context.  I<which> may be
'cancel' or 'next'.

Does not return.

=cut

sub return_redirect {
    my($self, $model, $which) = @_;
    my($req) = $model->get_request;
    my($c) = $self->internal_get;
    unless ($c->{form}) {
	if ($which eq 'cancel' && $c->{cancel_task}) {
	    _trace('no form, client_redirect: ', $c->{cancel_task}) if $_TRACE;
	    # If there is no form, redirect to client so looks
	    # better.  get_context_from_request will do the right thing
	    # and return the stacked context.
	    $req->client_redirect($c->{cancel_task}, $c->{realm},
		   $c->{query}, $c->{path_info});
	    # DOES NOT RETURN
	}

	# Next or cancel (not form)
	_trace('no form, client_redirect: ', $c->{unwind_task},
	    '?', $c->{query}) if $_TRACE;
	# If there is no form, redirect to client so looks
	# better.
	$req->client_redirect(
	    $c->{unwind_task}, $c->{realm}, $c->{query}, $c->{path_info});
	# DOES NOT RETURN
    }

    # Do an server redirect to context, because can't do
    # client redirect (no way to pass form state (reasonably)).
    # Indicate to the next form that this is a SUBMIT_UNWIND
    # Make sure you use that form's SUBMIT_UNWIND button.
    # In the cancel case, we chain the cancels.

    # Initializes context
    my($f) = $c->{form};
    $f->{$model->NEXT_FIELD} = $which eq 'cancel' ? 'cancel' : 'unwind';

    # Redirect calls model back in get_context_from_request
    _trace('have form, server_redirect: ', $c->{unwind_task},
	'?', $c->{query}) if $_TRACE;
    $req->server_redirect(
	$c->{unwind_task}, $c->{realm}, $c->{query}, $f, $c->{path_info});
    # DOES NOT RETURN
}

#=PRIVATE METHODS

# _format_hash(string_ref res, hash_ref c, string which)
#
# Joins the hash if defined and calls format_string.
#
sub _format_hash {
    my($res, $c, $which) = @_;
    my($h) = $c->{$which};
    _format_string($res, $which, join($_HASH_CHAR, map {
	defined($h->{$_}) ? ($_, $h->{$_}) : ()} keys(%$h)))
	if $h;
    return;
}

# _format_realm(string_ref res, hash_ref c)
#
# Gets owner_name.  If defined, formats as string.
#
sub _format_realm {
    my($res, $c) = @_;
    return unless $c->{realm};
    my($name) = $c->{realm}->unsafe_get('owner_name');
    _format_string($res, 'realm', $name)
	if defined($name);
    return;
}

# _format_string(string_ref res, string which, string value)
#
# Formats the string Base64 and appends to $res if defined.
#
sub _format_string {
    my($res, $which, $value) = @_;
    $$res .= $_KEY_TO_CHAR{$which}
	. Bivio::MIME::Base64->http_encode($value)
	. $_SEPARATOR
	if defined($value) && length($value);
    return;
}

# _format_task(string_ref res, hash_ref c, string which)
#
# Converts to an int if defined and calls format_string.
#
sub _format_task {
    my($res, $c, $which) = @_;
    _format_string($res, $which, $c->{$which}->as_int)
	if $c->{$which};
    return;
}

# _parse_error(proto, Bivio::Biz::FormModel model, string value, string which, string msg) : hash_ref
#
# Output a warning and return the empty context if requested.  $proto
# only needed if you want an new_empty() call.
#
sub _parse_error {
    my($proto, $model, $value, $which, $msg) = @_;
    Bivio::IO::Alert->warn(ref($model), ': attr=', $which,
	', value=', $value, ', msg=', $msg);
    # Don't do any work if in a void context
    return $proto && $proto->new_empty($model);
}

# _parse_hash(Bivio::Biz::FormModel model, hash_ref c, string which)
#
# Parses a hash from the context literal.
#
sub _parse_hash {
    my($model, $c, $which) = @_;
    # Not an error if undefined
    unless (defined($c->{$which})) {
	$c->{$which} = undef;
	return;
    }
    my(@v) = split(/$_HASH_CHAR/o, $c->{$which});
    # Handle uneven case.
    push(@v, undef)
	if int(@v) % 2;
    $c->{$which} = {@v};
    return;
}

# _parse_path_info(Bivio::Biz::FormModel model, hash_ref c)
#
# Checks path_info is correct.
#
sub _parse_path_info {
    my($proto, $model, $c) = @_;
    # Not an error if undefined
    unless (defined($c->{path_info})) {
	$c->{path_info} = undef;
	return;
    }
    unless ($c->{path_info} =~ m!^/!) {
	# Defaults to undef, i.e. no query or form
	_parse_error(undef, $model, $c->{path_info}, 'path_info',
		"path_info doesn't begin with slash");
	$c->{path_info} = undef;
    }
    return;
}

# _parse_realm(Bivio::Biz::FormModel model, hash_ref c) : Bivio::Auth::Realm
#
# Returns the realm contained in $realm.  Checks for general,
# etc.  Returns undef if it can't set.
#
sub _parse_realm {
    my($model, $c) = @_;
    my($v) = $c->{realm};
    # Not an error if undefined
    unless (defined($v)) {
	$c->{realm} = undef;
	return;
    }
    my($req) = $model->get_request;
    my($realm) = $req->get('auth_realm');
    my($name) = $realm->unsafe_get('owner_name');
    if (defined($name) && $name eq $v) {
	_trace($realm, ': matches auth_realm') if $_TRACE;
	$c->{realm} = $realm;
	return;
    }
    my($o) = Bivio::Biz::Model::RealmOwner->new($req);
    if ($o->unauth_load(name => $v)) {
	# This will blow if $o is "general".  Someone had to have hacked it.
	$c->{realm} = Bivio::Auth::Realm->new($o);
    }
    else {
	# Defaults to undef, use default realm.
	_parse_error(undef, $model, $v, 'realm',
		'realm not found');
	$c->{realm} = undef;
    }
    return;
}

# _parse_task(Bivio::Biz::FormModel model, hash_ref c, string which) : boolean
#
# Maps the number to a task id.  Clears and returns false if it couldn't map.
#
sub _parse_task {
    my($model, $c, $which) = @_;
    my($num) = $c->{$which};
    # Don't output an error, but return false.  The error is output
    # by new_from_literal in any event.
    unless (defined($num)) {
	$c->{$which} = undef;
	return 0;
    }
    unless ($num =~ /^\d+$/) {
	_parse_error(undef, $model, $num, $which, 'task is not a number');
	$c->{$which} = undef;
	return 0;
    }
    $c->{$which} = Bivio::Agent::TaskId->unsafe_from_any($num);
    unless ($c->{$which}) {
	_parse_error(undef, $model, $num, $which, 'task not found');
	return 0;
    }
    return 1;
}


=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
