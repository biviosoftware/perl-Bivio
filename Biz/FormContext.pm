# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::FormContext;
use strict;
$Bivio::Biz::FormContext::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::FormContext - initializes, parses, and stringifies FormModel context

=head1 SYNOPSIS

    use Bivio::Biz::FormContext;
    my($hash) = Bivio::Biz::FormContext->from_literal($form_model, $string);
    my($string) = Bivio::Biz::FormContext->to_literal($req, $hash);
    my($hash) = Bivio::Biz::FormContext->empty($form_model);

=cut

use Bivio::UNIVERSAL;
@Bivio::Biz::FormContext::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Biz::FormContext> is a utility module for
L<Bivio::Biz::FormModel|Bivio::Biz::FormModel>.  It initializes,
parses, and stringifies a form's context.  FormModel sets the
context from the form state in
L<Bivio::Biz::FormModel::get_context_from_request|Bivio::Biz::FormModel/"get_context_from_request">.
The two classes are therefore very tightly coupled.

A form context is a hash_ref containing attributes which tell the
FormModel how to "unwind", i.e. how to go back to what the user
was doing before the current form.  Contexts may be nested, which
adds to the complexity.

Since contexts can be nested, they can be long.  The stringified version is
"compact".  The structure is:

   <char><munged-base64> "!" <char><munged-base64> ...

The munged-base64 encoding may contain a serialized hash, realm name, or
nested context.  We call it munged-base64, because '=' is replaced with
'_'.  Equals (=) is a lousy character for uris and forms, so we use
an extra level of substitution.

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
use Bivio::IO::Trace;
use MIME::Base64 ();

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
# Character which precedes a proxy realm.
my($_PROXY_CHAR) = '-';
# Base64 uses '=' for a fill character which doesn't work well in
# query strings so we substistute something else
my($_EQUALS_SUBSTITUTE) = '_';

=head1 METHODS

=cut

=for html <a name="empty"></a>

=head2 static empty(Bivio::Biz::FormModel model) : hash_ref

Returns the empty context for the current task and realm.

=cut

sub empty {
    my(undef, $model) = @_;
    my($req) = $model->get_request;
    my($realm) = $req->get('auth_realm');
    $realm = undef if $realm->get('type') == Bivio::Auth::RealmType::GENERAL();
    my($task) = $req->get('task');
    return {
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
    };
}

=for html <a name="from_literal"></a>

=head2 static from_literal(Bivio::Biz::FormModel model, string value) : hash_ref

Parses the form context from the query or the form.  Errors result in
a warning and _initial_context being returned.

=cut

sub from_literal {
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
	    return _parse_error($model, $item, $which,
		    'missing or invalid element');
	}

	$which = $_CHAR_TO_KEY{$which};
#TODO: Need to catch decode errors.  MIME::Base64 outputs warnings, but
#      silently succeeds.
	$enc =~ s/$_EQUALS_SUBSTITUTE/=/og;
	$c->{$which} = MIME::Base64::decode($enc);
    }

    # Parse the decoded fields and validate. unwind_task must be checked first,
    # because it may clear all the rest of the state
    unless (_parse_task($model, $c, 'unwind_task')) {
	$$err = 1 if $err;
	return _parse_error($model, undef, 'unwind_task',
		'missing or bad unwind_task');
    }

    _parse_task($model, $c, 'cancel_task');
    _parse_path_info($model, $c);
    _parse_hash($model, $c, 'form');
    _parse_hash($model, $c, 'query');
    _parse_realm($model, $c);

    if (defined($c->{form_context})) {
	my($sub_err);
	$c->{form_context} = $proto->from_literal($model, $c->{form_context},
		\$sub_err);
	$c->{form_context} = undef if $sub_err;
    }

    $c->{form_model} = Bivio::Agent::Task->get_by_id($c->{unwind_task})
	    ->get('form_model');
    return $c;
}

=for html <a name="to_literal"></a>

=head2 to_literal(Bivio::Agent::Request req, hash_ref context) : string

Returns the stringified version of I<context>.  I<req> is used to
gather state, e.g. default realm.

=cut

sub to_literal {
    my($proto, $req, $context) = @_;
    my($res) = '';

    _trace('incoming: ', $context) if $_TRACE;

    # The order is the same as @_CHARS.  nice for debugging
    _format_task(\$res, $context, 'unwind_task');

    # Don't format cancel, if it doesn't contain anything
    _format_task(\$res, $context, 'cancel_task')
	    if defined($context->{cancel_task}) &&
		    $context->{cancel_task} != $context->{unwind_task};

    _format_realm(\$res, $context);
    _format_hash(\$res, $context, 'query');
    _format_hash(\$res, $context, 'form');
    _format_string(\$res, 'path_info', $context->{path_info});

    # Recurse nested context only if we aren't reentering same task
    _format_string(\$res, 'form_context',
	    $proto->to_literal($req, $context->{form_context}))
	    if $context->{form_context}
		    && $context->{form_context}->{unwind_task}
			    != $context->{unwind_task};

    # Remove trailing separator
    chop($res);
    _trace($res) if $_TRACE;
    return $res;
}

#=PRIVATE METHODS

# _format_hash(string_ref res, hash_ref c, string which)
#
# Joins the hash if defined and calls format_string.
#
sub _format_hash {
    my($res, $c, $which) = @_;
    my($h) = $c->{$which};
    return unless $h;

    _format_string($res, $which, join($_HASH_CHAR, map {
	defined($h->{$_}) ? ($_, $h->{$_}) : ()} keys(%$h)));
    return;
}

# _format_realm(string_ref res, hash_ref c)
#
# Gets owner_name.  If defined, formats as string.  Prefixes with
# $_PROXY_CHAR if proxy realm.
#
sub _format_realm {
    my($res, $c) = @_;
    return unless $c->{realm};
    my($name) = $c->{realm}->unsafe_get('owner_name');
    return unless defined($name);

    $name = $_PROXY_CHAR.$name
	    if $c->{realm}->get('type') == Bivio::Auth::RealmType::PROXY();

    _format_string($res, 'realm', $name);
    return;
}

# _format_string(string_ref res, string which, string value)
#
# Formats the string Base64 and appends to $res if defined.
#
sub _format_string {
    my($res, $which, $value) = @_;
    return unless defined($value) && length($value);

    my($v) = MIME::Base64::encode($value, '');
    $v =~ s/=/$_EQUALS_SUBSTITUTE/og;
    $$res .= $_KEY_TO_CHAR{$which}.$v.$_SEPARATOR;
    return;
}

# _format_task(string_ref res, hash_ref c, string which)
#
# Converts to an int if defined and calls format_string.
#
sub _format_task {
    my($res, $c, $which) = @_;
    return unless $c->{$which};

    _format_string($res, $which, $c->{$which}->as_int);
    return;
}

# _parse_error(Bivio::Biz::FormModel model, string value, string which, string msg) : hash_ref
#
# Output a warning and return the empty context if requested.
#
sub _parse_error {
    my($model, $value, $which, $msg) = @_;

    Bivio::IO::Alert->warn(ref($model), ': attr=', $which,
	    ', value=', $value, ', msg=', $msg);
    # Don't do any work if in a void context
    return unless defined(wantarray);

    return __PACKAGE__->empty($model);
}

# _parse_hash(Bivio::Biz::FormModel model, hash_ref c, string which)
#
# Parses a hash from the context literal.
#
sub _parse_hash {
    my($model, $c, $which) = @_;

    # Not an error if undefined
    return unless defined($c->{$which});

    my(@v) = split(/$_HASH_CHAR/o, $c->{$which});

    # Handle uneven or empty hash case.
    push(@v, undef) if int(@v) % 2;

    $c->{$which} = {@v};
    return;
}

# _parse_hash(Bivio::Biz::FormModel model, hash_ref c)
#
# Checks path_info is correct.
#
sub _parse_path_info {
    my($model, $c) = @_;

    # Not an error if undefined
    return unless defined($c->{path_info});

    unless ($c->{path_info} =~ m!^/!) {
	# Defaults to undef, i.e. no query or form
	_parse_error($model, $c->{path_info}, 'path_info',
		"path_info doesn't begin with slash");
	$c->{path_info} = undef;
    }
    return;
}

# _parse_realm(Bivio::Biz::FormModel model, hash_ref c) : Bivio::Auth::Realm
#
# Returns the realm contained in $realm.  Checks for proxy realms, general,
# etc.  Returns undef if it can't set.
#
sub _parse_realm {
    my($model, $c) = @_;
    my($v) = $c->{realm};

    # Not an error if undefined
    return unless defined($v);

    # If auth_realm and incoming are same, leave as undef.
    my($is_proxy) = $v =~ s/^$_PROXY_CHAR//;

    if ($is_proxy) {
#TODO: Delete this eventually.
	# Dies if not found.  Ok since proxies aren't long for this world
	$c->{realm} = Bivio::Auth::Realm::Proxy->from_name($v);
	_trace($c->{realm}, ': is a proxy realm') if $_TRACE;
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
	_parse_error($model, $v, 'realm',
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
    # by from_literal in any event.
    return 0 unless defined($num);

    unless ($num =~ /^\d+$/) {
	_parse_error($model, $num, $which, 'task is not a number');
	$c->{$which} = undef;
	return 0;
    }

    $c->{$which} = Bivio::Agent::TaskId->unsafe_from_any($num);
    unless ($c->{$which}) {
	_parse_error($model, $num, $which, 'task not found');
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
