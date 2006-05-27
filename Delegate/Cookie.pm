# Copyright (c) 2004 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Delegate::Cookie;
use strict;
$Bivio::Delegate::Cookie::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Delegate::Cookie::VERSION;

=head1 NAME

Bivio::Delegate::Cookie - HTTP cookie management

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Delegate::Cookie;

=cut

=head1 EXTENDS

L<Bivio::Collection::Attributes>

=cut

use Bivio::Collection::Attributes;
@Bivio::Delegate::Cookie::ISA = ('Bivio::Collection::Attributes');

=head1 DESCRIPTION

C<Bivio::Delegate::Cookie> manages cookies arriving via HTTP and
returns cookies to the user. By default cookies are persistent. Temporary
cookies do not set the 'expires' field. A cookie can be set to time-out
after a period of activity. Cookie fields must begin with a letter.

=cut

=head1 CONSTANTS

=cut

=for html <a name="DATE_TIME_FIELD"></a>

=head2 DATE_TIME_FIELD : string

String name of the time field, which is set to C<time> every time a cookie is
set.  Sets to L<Bivio::Type::DateTime|Bivio::Type::DateTime>.

=cut

sub DATE_TIME_FIELD {
    return 'd';
}

#=IMPORTS
use Bivio::Die;
use Bivio::IO::Alert;
use Bivio::IO::Trace;
use Bivio::Type::DateTime;
use Bivio::Type::Secret;
use Bivio::UI::Facade;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
# This field is used only locally.  See header_out()
my($_MODIFIED_FIELD) = '_modified';
my($_SEP) = "\036";
#TODO: Need to format dynamically
my($_EXPIRES) = "; expires=Thu, 15 Apr 2020 20:00:00 GMT";
Bivio::IO::Config->register(my $_CFG = {
    domain => undef,
    tag => 'A',
    is_temporary => 0,
    session_timeout_seconds => undef,
});
my($_DT) = 'Bivio::Type::DateTime';

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Agent::Request req, Apache::Request r) : Bivio::Delegate::PersistentCookie

Creates a new cookie processor.

=cut

sub new {
    my($proto, $req, $r) = @_;
    return $proto->SUPER::new(
        $req->get('Type.UserAgent')->is_browser
            ? _parse($proto, $r->header_in('Cookie') || '')
            : {});
}

=head1 METHODS

=cut

=for html <a name="assert_is_ok"></a>

=head2 static assert_is_ok(Bivio::Agent::Request req)

Check to see if cookie has been returned.

=cut

sub assert_is_ok {
    my($proto, $req) = @_;
    return unless $req->get('Type.UserAgent')->is_browser;
    $req->throw_die('MISSING_COOKIES', {
	client_addr => $req->unsafe_get('client_addr'),
    }) unless $req->get('cookie')->unsafe_get($proto->DATE_TIME_FIELD);
    return;
}

=for html <a name="delete"></a>

=head2 delete(string key, ...)

Removes the named attribute(s) from the map.  They needn't exist.

=cut

sub delete {
    my($self) = shift;
    _trace(\@_) if $_TRACE;
    my($res) = $self->SUPER::delete(@_);
    # set modified, done indirectly because put() validates keys
    $self->put;
    return $res;
}

=for html <a name="delete_all"></a>

=head2 delete_all()

B<NOT ALLOWED.>

=cut

sub delete_all {
    die('not supported');
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item domain : string [undef]

If defined, maps the cookie domain to be used in cookies.  Otherwise,
cookies are not returned with a domain (normal for testing).

=item tag : string [A]

Name of the tag.  Will be upcased.

=item is_temporary : boolean [0]

If true, the cookie is not stored on the browser's disk and will be
lost when the browser is closed.

=item session_timeout_seconds : int [0]

Sets the session time-out in seconds. A zero value has no timeout. This
value should be set only for temporary cookies.

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    Bivio::Die->die($cfg->{domain}, ': domain must begin with dot (.)')
        if defined($cfg->{domain}) && $cfg->{domain} !~ /^\./;
    $_CFG = {%{$cfg}, tag => uc($cfg->{tag})};
    return;
}

=for html <a name="header_out"></a>

=head2 header_out(Bivio::Agent::Request req, Apache::Request r) : boolean

Writes the header.  If the cookie isn't written (not modified), returns
false.

=cut

sub header_out {
    my($self, $req, $r) = @_;
    my($fields) = $self->internal_get;
    # Only set if modified and a browser.
    return 0 unless $req->get('Type.UserAgent')->is_browser;
    return 0 unless $fields->{$_MODIFIED_FIELD}
        || $_CFG->{session_timeout_seconds};
    my($domain) = $_CFG->{domain}
        ? Bivio::UI::Facade->get_from_request_or_self($req)
            ->unsafe_get('cookie_domain') || $_CFG->{domain}
        : undef;
    # don't send header unless we are in the correct server
    return 0 if $domain
	&& $r->server->server_hostname !~ /\Q$domain\E$/i;

    # Set the time field so we can see if the cookie comes back and
    # for sessions.
    $fields->{$self->DATE_TIME_FIELD} = $_DT->now;

    # Since our fields are encrypted, we don't need to return a "secure"
    # cookie.  Allows us to track users better (on non-secure portions of the
    # site).
    my($p) = '; path=/';
    $p .= "; domain=$domain" if $domain;
    $p .= $_EXPIRES
        unless $_CFG->{is_temporary};
    _trace('data=', $fields) if $_TRACE;
    my($clear_text) = '';

    while (my($k, $v) = each(%$fields)) {
	next unless $k =~ /^[a-z]/i;
	# Only append the field if it is defined
	$clear_text .= "$k$_SEP$v$_SEP" if defined($v);
    }
    chop($clear_text);
    my($value) = $_CFG->{tag}
	. '=' . Bivio::Type::Secret->encrypt_http_base64($clear_text)
	. $p;
    _trace($value) if $_TRACE;
    $r->header_out('Set-Cookie', $value);
    return 1;
}

=for html <a name="put"></a>

=head2 put(string key, string value, ...)

Adds or replaces the named value(s).

=cut

sub put {
    my($self) = shift;
    my(%values) = @_;

    # Assert keys begin with a letter
    foreach my $key (keys(%values)) {
        Bivio::Die->die('keys must start with a letter: ', $key)
            unless $key =~ /^[a-z]/i;
    }
    _trace(\@_) if $_TRACE;
    return $self->SUPER::put(@_, $_MODIFIED_FIELD => 1);
}

#=PRIVATE METHODS

# _parse(proto, string cookie) : hash_ref
#
# Parses the attributes out of the cookie.
#
sub _parse {
    my($proto, $cookie) = @_;
    _trace($cookie) if $_TRACE;
    my($values) = _parse_values($proto, $cookie);
    # If bad, clear the cookie entirely.
    return {$_MODIFIED_FIELD => 1}
        unless $values;

    if ($_CFG->{session_timeout_seconds}) {
        my($date) = $_DT->from_literal($values->{$proto->DATE_TIME_FIELD});

        if ($date && $_DT->compare($_DT->now,
            $_DT->add_seconds($date, $_CFG->{session_timeout_seconds}))
            > 0) {
            _trace('session timed out') if $_TRACE;
            # return valid values with no info except date
            return {$proto->DATE_TIME_FIELD => $date};
        }
    }
    return $values;
}

# _parse_items(proto, string cookie) : hash_ref
#
# Parses our cookie key/value pairs. Issues a warning if a key is duplicated.
#
sub _parse_items {
    my($proto, $cookie) = @_;
    my($items) = {};

    foreach my $f (split(/\s*[;,]\s*/, $cookie)) {
	my($k, $v) = split(/\s*=\s*/, $f, 2);

	# We ignore all other parts of the cookie
	unless (defined($k) && defined($v)) {
	    _trace($k, ': ignoring other element') if $_TRACE;
	    next;
	}

	# Did we get our tag back?
	$k = uc($k);
	unless ($k eq $_CFG->{tag}) {
	    _trace('tag from another server or old tag: ', $k) if $_TRACE;
	    next;
	}

        # we only expect one cookie, if there are more, there may
        # be a problem with a stale cookie with a switched cookie domain
        if (exists($items->{$k})) {
	    Bivio::IO::Alert->warn('duplicate cookie value for key: ', $k,
                ', ', $items->{$k}, ' and ', $v);
            next;
        }
        $items->{$k} = $v;
    }
    return $items;
}

# _parse_values(proto, string cookie) : hash_ref
#
# Parses out our cookies values. Ignores other keys.
# Returns undef on failure.
#
sub _parse_values {
    my($proto, $cookie) = @_;
    my($values) = {};

    # Our cookies don't have ';' in them.  If someone sends a cookie
    # back with ';' in it, well, it won't initialize correctly
    # New cookies have ',' to separate them.  The attributes of a cookie
    # are separated by ';' and the names begin with '$'.  We ignore
    # all attributes except our tag.
    my($items) = _parse_items($proto, $cookie);

    while (my($k, $v) = each(%$items)) {
	# Some cookies come back with quotes, strip 'em.
	$v =~ s/"//g;
	my($s) = Bivio::Type::Secret->decrypt_http_base64($v);
	unless ($s) {
	    # Error decoding.  Warning already output by Base64.
	    _trace('unable to decode: ', $v) if $_TRACE;
            return undef;
	}

	my(@v) = split(/$_SEP/o, $s);
	_trace('data=', \@v) if $_TRACE;
	# Make sure we have an even number of elements and then convert to hash
	push(@v, '') if int(@v) % 2;
	my(%v) = @v;

	# The date time field is checked for validity by DateTime.
	unless ((Bivio::Type::DateTime->from_literal(
	    $v{$proto->DATE_TIME_FIELD}))[0]) {
	    # Bad cookie.  This will help us track users who have
	    # cookie problems.
	    Bivio::IO::Alert->warn(
		'invalid cookie: encrypted=', $v, ' decrypted=', \@v);
            return undef;
	}

	# Copy over all the field values; they will be parsed by the handlers
	while (my($k, $v) = each(%v)) {
	    $values->{$k} = $v;
	}
    }
    return $values;
}

=head1 COPYRIGHT

Copyright (c) 2004 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
