# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::HTTP::Cookie;
use strict;
$Bivio::Agent::HTTP::Cookie::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Agent::HTTP::Cookie - manage HTTP cookies

=head1 SYNOPSIS

    use Bivio::Agent::HTTP::Cookie;
    my($cookie) = Bivio::Agent::HTTP::Cookie->new($req, $r);
    $cookie->header_out($r);

=head1 EXTENDS

L<Bivio::Collection::Attributes>

=cut

use Bivio::Collection::Attributes;
@Bivio::Agent::HTTP::Cookie::ISA = ('Bivio::Collection::Attributes');

=head1 DESCRIPTION

C<Bivio::Agent::HTTP::Cookie> manages the cookie in the HTTP header.
There are two tags: persistent and volatile.  Persistent mantains
the user state, time zone, etc.  Volatile maintains the logout
expiry, if any. The values are encrypted.

Handlers are called when a new cookie is created.  See L<register|"register">.
This allows distributed configuration of cookie handlers.

Cookie fields are kept short as there is limited storage space on
the client and we store the cookie encrypted which explodes its
size.  The following field names are currently in use:

=over 4

=item e [persistent]

The URI for first-time entries into bivio.
See L<Bivio::Biz::Action::Referral|Bivio::Biz::Action::Referral>.

=item l [persistent or volatile]

Is the integer value of L<Bivio::Type::LoginCookie|Bivio::Type::LoginCookie>.
See L<Bivio::Biz::Model::LoginForm|Bivio::Biz::Model::LoginForm>.

=item modified [internal]

Used internally to indicate the cookie was modified and must be
reset.  It is never sent to the client.

=item ri [persistent]

RealmInvite field.  The user has clicked on a URI which contains
a valid realm invite.

=time rr [persistent]

Referer realm_id.  Only set temporarily.  See the code in
L<Bivio::Biz::Action::Referral|Bivio::Biz::Action::Referral>.

=item ru [persistent]

Referer uri.  Only set temporarily.  See the code in
L<Bivio::Biz::Action::Referral|Bivio::Biz::Action::Referral>.

=item su [persistent]

This field is set by
L<Bivio::Biz::Model::SubstituteUserForm|Bivio::Biz::Model::SubstituteUserForm>
when the user has been substituted succesfully.  It is cleared by
L<Bivio::Biz::Action::Logout|Bivio::Biz::Action::Logout>.

=item t [volatile and persistent]

Time field.  Makes the cypher better.

=item tz [persistent]

timezone (actually timezone offset).  It is set by
L<Bivio::Biz::FormModel|Bivio::Biz::FormModel>.
This module puts it on the Request after extracting it from the cookie.

=item u [persistent]

login id (realm_id) of the authenticated user. Not set if
"ref" or "u" is set.

=item v [persistent]

visitor_id is set only if "u" or "ref" isn't set.

=back

You may I<sparingly> add other fields, but be sure to
update this documentation.

=cut

=head1 CONSTANTS

=cut

=for html <a name="ENTRY_URI_FIELD"></a>

=head2 ENTRY_URI_FIELD : string

The URI for the first time a user has entered bivio.

=cut

sub ENTRY_URI_FIELD {
    return 'e';
}

=for html <a name="LOGIN_FIELD"></a>

=head2 LOGIN_FIELD : string

One of the L<Bivio::Type::LoginCookie|Bivio::Type::LoginCookie>
values.  It is stored in the persistent cookie if its value
is C<PERSISTENT>, else stored in the volatile cookie.  This is the
only field which is handled specially by header_out.

=cut

sub LOGIN_FIELD {
    return 'l';
}

=for html <a name="MODIFIED_FIELD"></a>

=head2 MODIFIED_FIELD : string

Used internally to indicate the cookie was modified.  Not passed back
in header_out.

=cut

sub MODIFIED_FIELD {
    return 'modified';
}

=for html <a name="REALM_INVITE_FIELD"></a>

=head2 REALM_INVITE_FIELD : string

Returns the realm_invite_id field name.  Is managed by
L<Bivio::Biz::Model::RealmInvite|Bivio::Biz::Model::RealmInvite>.

=cut

sub REALM_INVITE_FIELD {
    return 'ri';
}

=for html <a name="REFERER_REALM_FIELD"></a>

=head2 REFERER_REALM_FIELD : string

The realm_id in the referer field.  Only set temporarily.

Misspelling to match RFC2616.

=cut

sub REFERER_REALM_FIELD {
    return 'rr';
}

=for html <a name="REFERER_URI_FIELD"></a>

=head2 REFERER_URI_FIELD : string

The URI from the referer page.  Set temporarily.

Misspelling to match RFC2616.

=cut

sub REFERER_URI_FIELD {
    return 'ru';
}

=for html <a name="SEPARATOR"></a>

=head2 SEPARATOR : string

String used to separate stringified fields.  This is a non-printable
ascii character which cannot appear in values in the cookie.

=cut

sub SEPARATOR {
    return "\034";
}

=for html <a name="SU_FIELD"></a>

=head2 SU_FIELD : string

Returns substitute user field name.
Is managed by
L<Bivio::Biz::Model::SubstituteUser|Bivio::Biz::Model::SubstituteUser>
and
L<Bivio::Biz::Model::LogoutForm|Bivio::Biz::Model::LogoutForm>.

=cut

sub SU_FIELD {
    return 'su';
}

=for html <a name="TIMEZONE_FIELD"></a>

=head2 TIMEZONE_FIELD : string

Returns the timezone field name.  Is managed by
L<Bivio::Biz::FormModel|Bivio::Biz::FormModel>.

=cut

sub TIMEZONE_FIELD {
    return 'tz';
}

=for html <a name="USER_FIELD"></a>

=head2 USER_FIELD : string

user_id for this user.

=cut

sub USER_FIELD {
    return 'u';
}

=for html <a name="VISITOR_FIELD"></a>

=head2 VISITOR_FIELD : string

visitor_id for this browser.

=cut

sub VISITOR_FIELD {
    return 'v';
}

#=IMPORTS
# Don't import anything that might cause a circular import with Biz::Model
# @_HANDLERS must be initialized before the Biz::Model code is executed.
use Bivio::IO::Alert;
use Bivio::IO::Config;
use Bivio::IO::Trace;
use Bivio::Type::LoginCookie;
use Bivio::Util;
use Crypt::CBC;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_USER_FIELD) = 'u';
my($_REMOTE_IP_FIELD) = 'i';
my($_DOMAIN) = undef;
my($_CIPHER) = undef;
my($_PERSISTENT_TAG_PREFIX) = 'E';
my($_VOLATILE_TAG_PREFIX) = 'F';
my($_PERSISTENT_TAG) = $_PERSISTENT_TAG_PREFIX;
my($_VOLATILE_TAG) = $_VOLATILE_TAG_PREFIX;
my($_TAG) = '';
my($_TIMEZONE_FIELD) = TIMEZONE_FIELD();
my($_TIME_FIELD) = 't';
my($_SU_FIELD) = SU_FIELD();
my($_LOGIN_PERSISTENT) = Bivio::Type::LoginCookie->PERSISTENT->as_int;
my($_SEP) = SEPARATOR();
my(@_HANDLERS);
# LOGIN_FIELD is handled specially
my(@_PERSISTENT_FIELDS) = (REALM_INVITE_FIELD(),
	REFERER_REALM_FIELD(), REFERER_URI_FIELD(), $_TIME_FIELD,
	TIMEZONE_FIELD(), USER_FIELD());
my(@_VOLATILE_FIELDS) = (SU_FIELD(), $_TIME_FIELD);

Bivio::IO::Config->register({
    domain => $_DOMAIN,
    tag => $_TAG,
    key => Bivio::IO::Config->REQUIRED,
});


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Agent::Request req, Apache::Request r) : Bivio::Agent::HTTP::Cookie

Initializes the cookie object from the request.  Does not put anything
on the request, but upcalls the cookie handlers.

=cut

sub new {
    my($proto, $req, $r) = @_;
    my($cookie) = $r->header_in('Cookie');
    _trace($cookie) if $_TRACE;
    my($fields) = _parse($cookie || '');
    my($self) = Bivio::Collection::Attributes::new($proto, $fields);
    foreach my $h (@_HANDLERS) {
	$h->handle_cookie_in($self, $req);
    }
    return $self;
}

=head1 METHODS

=cut

=for html <a name="delete"></a>

=head2 delete(string key, ...)

Removes the named attribute(s) from the map.  They needn't exist.

=cut

sub delete {
    my($self) = shift;
    my($res) = $self->SUPER::delete(@_);
    $self->put(MODIFIED_FIELD() => 1);
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

=item key : string (required)

How to encrypt the cookie.

=item tag : string ['']

A special tag name that appears in the C<Set-Cookie> line in the HTTP header
which identifies this particular server.   For testing, should set
to your user name.

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    Carp::croak("$cfg->{domain}: domain must have two dots in it")
		unless !$cfg->{domain} || $cfg->{domain} =~ /\..*\./;
    $_DOMAIN = $cfg->{domain};
    $_CIPHER = Crypt::CBC->new($cfg->{key}, 'IDEA');
    $_TAG = uc($cfg->{tag});
    $_PERSISTENT_TAG = $_PERSISTENT_TAG_PREFIX.$_TAG;
    $_VOLATILE_TAG = $_VOLATILE_TAG_PREFIX.$_TAG;
    return;
}

=for html <a name="handle_cookie_in"></a>

=head2 static abstract handle_cookie_in(Bivio::Agent::HTTP::Cookie cookie, Bivio::Agent::Request req)

Processes one or more cookie fields.  Objects/classes should call
L<register|"register"> in their initialization bodies to get upcalled
when a cookie comes in.

This is an interface specification.  This is not a super-class of
cookie handlers.

There may be a I<handle_cookie_out> someday, hence the name of this routine.

=cut

sub handle_cookie_in {
    die('abstract');
}

=for html <a name="header_out"></a>

=head2 header_out(Apache::Request r) : boolean

Sets the cookie in the header. Returns true if the cookie was modified
and set thusly.

=cut

sub header_out {
    my($self, $r) = @_;
    my($fields) = $self->internal_get;

    return 0 unless $fields->{MODIFIED_FIELD()};

    # Since our fields is encrypted, we don't need to header_out "secure".
    # Allows us to track users better (on non-secure portions of the site).
    my($p) = '; path=/';
    $p .= "; domain=$_DOMAIN" if $_DOMAIN;
    my($v) = $p;

    # Yahoo uses this magic date to mean forever.  We use it, too.
    $p .= '; expires=Thu, 15 Apr 2010 20:00:00 GMT';

    # Add in a random factor (not checked, just helps CBC)
    $fields->{$_TIME_FIELD} = time;
    _trace('data=', $fields) if $_TRACE;

    # Encrypt the fields
    my($pc) = _encrypt($fields, \@_PERSISTENT_FIELDS, $_PERSISTENT_TAG, 1);
    my($vc) = _encrypt($fields, \@_VOLATILE_FIELDS, $_VOLATILE_TAG, 0);

    # This is a hack, because mod_perl uses a hash to store header_out.
    # You can't set two cookies, but Yahoo does this.  It's like that
    # all browsers can't handled multiple cookies on one line.
    $r->header_out('Set-Cookie', $pc.$p."\r\nSet-Cookie: ".$vc.$v);

    return 1;
}

=for html <a name="put"></a>

=head2 put(string key, string value, ...)

Adds or replaces the named value(s).

=cut

sub put {
    return shift->SUPER::put(@_, MODIFIED_FIELD(), 1);
}

=for html <a name="register"></a>

=head2 register(proto handler)

Registers a cookie handler if not already registered.   The I<handler> must
support L<handle_cookie_in|"handle_cookie_in">.

=cut

sub register {
    my($self, $handler) = @_;
    return if grep($_ eq $handler, @_HANDLERS);
    push(@_HANDLERS, $handler);
    return;
}

#=PRIVATE METHODS

# _encrypt(hash_ref fields, array_ref to_copy, string tag, boolean is_persistent) : string
#
# Encrypt the fields in to_copy and prefix with tag.  If is_persistent,
# only copy login_field if PERSISTENT.
#
sub _encrypt {
    my($fields, $to_copy, $tag, $is_persistent) = @_;

    # Make a copy to ensure we only
    my(@to_copy_tmp) = @$to_copy;
    if (defined($fields->{LOGIN_FIELD()})) {
	if ($fields->{LOGIN_FIELD()} == $_LOGIN_PERSISTENT) {
	    push(@to_copy_tmp, LOGIN_FIELD()) if $is_persistent;
	}
	else {
	    push(@to_copy_tmp, LOGIN_FIELD()) unless $is_persistent;
	}
    }

    # Concat the to_copy fields and values
    my($res) = '';
    foreach my $f (@to_copy_tmp) {
	$res .= $f.$_SEP.$fields->{$f}.$_SEP if defined($fields->{$f});
    }

    # remove trailing $_SEP
    chop($res);

    $res = $_CIPHER->encrypt_hex($res);
    _trace($is_persistent ? 'persistent-length=' : 'volatile-length=',
	    length($res)) if $_TRACE;

    # encrypt and store as value
    return $tag.'='.$res;
}

# _parse(string cookie) : hash_ref
#
# Parses the cookie into fields.
#
sub _parse {
    my($cookie) = @_;
    my($fields) = {};
    # Our cookies don't have ';' in them.  If someone sends a cookie
    # back with ';' in it, well, it won't initialize correctly
    # New cookies have ',' to separate them.  The attributes of a cookie
    # are separated by ';' and the names begin with '$'.  We ignore
    # attributes.
    foreach my $f (split(/\s*[;,]\s*/, $cookie)) {
	my($k, $v) = split(/\s*=\s*/, $f, 2);

	if ($k =~ /\$/) {
	    _trace($k, ': ignoring attribute') if $_TRACE;
	    next;
	}

	$k = uc($k);
	unless ($k eq $_VOLATILE_TAG || $k eq $_PERSISTENT_TAG) {
	    _trace('tag from another server or old tag: ', $k) if $_TRACE;
	    next;
	}

	my($s) = $_CIPHER->decrypt_hex($v);
	my(@v) = split(/$_SEP/o, $s);
	_trace('data=', \@v) if $_TRACE;
	# Make sure we have an even number of elements and then convert to hash
	push(@v, '') if int(@v) % 2;
	my(%v) = @v;

	# If we don't have a time field, the cookie is invalid.  Can't have
	# time in the future.  We assume all our servers are time synchronized.
	unless ($v{$_TIME_FIELD} && $v{$_TIME_FIELD} <= time) {
	    # Bad cookie
	    _trace('unable to decrypt cookie') if $_TRACE;

	    # force a new cookie to be written
	    $fields->{MODIFIED_FIELD()} = 1;
	    next;
	}

	# Copy over all the field values; they will be parsed by the handler
	while (my($k, $v) = each(%v)) {
	    $fields->{$k} = $v;
	}
    }
    return $fields;
}

=head1 SEE ALSO

RFC2616 (HTTP/1.1), RFC1945 (HTTP/1.0), RFC1867 (multipart/form-data),
RFC2109 (Cookies), RFC1806 (Content-Disposition), RFC1521 (MIME)

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
