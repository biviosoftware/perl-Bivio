# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::HTTP::Cookie;
use strict;
$Bivio::Agent::HTTP::Cookie::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Agent::HTTP::Cookie - manage HTTP cookies

=head1 SYNOPSIS

    use Bivio::Agent::HTTP::Cookie;
    my($user) = Bivio::Agent::HTTP::Cookie->parse($req, $r);
    Bivio::Agent::HTTP::Cookie->set($req, $r);

=cut

use Bivio::UNIVERSAL;
@Bivio::Agent::HTTP::Cookie::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Agent::HTTP::Cookie> manages the cookie in the HTTP header.
We send a single value (the tag) back to the user.  (Initially, I
tried to send a version along with this, but IE doesn't seem to
return multiple values.)
The value is encrypted or url-encoded depending on the configuration.

The contents of the tag-value is returned as a hash_ref.

Cookie fields are kept short as there is limited storage space on
the client.  The following field names are currently in use:

=over 4

=item i

ip address of client (C<$r-E<gt>connection->remote_ip>)

=item su

This field is set by
L<Bivio::Biz::Model::SubstituteUserForm|Bivio::Biz::Model::SubstituteUserForm>
when the user has been substituted succesfully.  It is cleared by
L<Bivio::Biz::Action::Logout|Bivio::Biz::Action::Logout>.

=item tz

timezone (actually timezone offset).  It is set by
L<Bivio::Biz::FormModel|Bivio::Biz::FormModel>.
This module puts it on the request.

=item ri

RealmInvite field.  The user has clicked on a URL which contains
a valid realm invite.

=item u

login id (realm_id) of the authenticated user.

=back

You may I<sparingly> add other fields, but be sure to
update this documentation.

=cut


=head1 CONSTANTS

=cut

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

=for html <a name="REALM_INVITE_FIELD"></a>

=head2 REALM_INVITE_FIELD : string

Returns the realm_invite_id field name.  Is managed by
L<Bivio::Biz::Model::RealmInvite|Bivio::Biz::Model::RealmInvite>.

=cut

sub REALM_INVITE_FIELD {
    return 'ri';
}

=for html <a name="TIMEZONE_FIELD"></a>

=head2 TIMEZONE_FIELD : string

Returns the timezone field name.  Is managed by
L<Bivio::Biz::FormModel|Bivio::Biz::FormModel>.

=cut

sub TIMEZONE_FIELD {
    return 'tz';
}

#=IMPORTS
use Bivio::Agent::HTTP::CookieState;
use Bivio::IO::Alert;
use Bivio::IO::Config;
use Bivio::IO::Trace;
use Bivio::Util;
use Crypt::CBC;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_USER_FIELD) = 'u';
my($_REMOTE_IP_FIELD) = 'i';
my($_DOMAIN) = undef;
my($_CIPHER) = undef;
my($_TAG) = 'D';
my($_TIMEZONE_FIELD) = TIMEZONE_FIELD();

Bivio::IO::Config->register({
    domain => $_DOMAIN,
    tag => $_TAG,
    key => Bivio::IO::Config->REQUIRED,
});

=head1 METHODS

=cut

=for html <a name="delete_field"></a>

=head2 delete_field(Bivio::Agent::Request req, string name) : string

Returns the field, if set.  Deletes it in any case.

=cut

sub delete_field {
    my(undef, $req, $name) = @_;
    my($cookie) = $req->unsafe_get('cookie');
    return undef unless $cookie;
    my($value) = $cookie->{$name};
    delete($cookie->{$name});
    return $value;
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item domain : string [undef]

If defined, maps the cookie domain to be used in cookies.  Otherwise,
cookies are not returned with a domain (normal for testing).

=item key : string (required)

How to encrypt the cookie.

=item tag : string ['D']

The name that appears in the C<Set-Cookie> line in the HTTP header
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
    return;
}

=for html <a name="parse"></a>

=head2 parse(Bivio::Agent::Request req, Apache::Request r) : Bivio::Biz::Model::RealmOwner

Returns the user encoded in the cookie, if it is parsed successfully from the
header.  Returns undef if there were any errors or no cookie.

=cut

sub parse {
    my(undef, $req, $r) = @_;
    my($cookie) = $r->header_in('Cookie');
    my($state) = Bivio::Agent::HTTP::CookieState::NOT_SET();
    my($data, $user);
    if (defined($cookie)) {
	# Our cookies don't have ';' in them.  If someone sends a cookie
	# back with ';' in it, well, it won't parse correctly
	foreach my $f (split(/\s*;\s*/, $cookie)) {
	    my($k, $v) = split(/\s*=\s*/, $f, 2);
	    $k = uc($k);
	    unless ($k eq $_TAG) {
		_trace('tag from another server: ', $k) if $_TRACE;
		next;
	    }
	    my($s) = $_CIPHER->decrypt_hex($v);
	    my(@v) = split(/$;/, $s);
	    # Make sure we have an even number of elements
	    push(@v, '') if int(@v) % 2;
	    $data = {@v};
	    _trace('data=', $data) if $_TRACE;
	    unless ($data->{$_REMOTE_IP_FIELD}) {
		$state = Bivio::Agent::HTTP::CookieState::NO_CLIENT();
		last;
	    }
	    if ($r->connection->remote_ip ne $data->{$_REMOTE_IP_FIELD}) {
		$state = Bivio::Agent::HTTP::CookieState::INVALID_CLIENT();
		last;
	    }
	    # We try to get the user now, because we know basically
	    # that everything in the cookie is ok.
	    #
	    # Note that the user field is not required, so it is not
	    # error for it not to be set.
	    if ($data->{$_USER_FIELD}) {
		$user = Bivio::Biz::Model::RealmOwner->new($req);
		unless ($user->unauth_load(
			realm_id => $data->{$_USER_FIELD})
			&& $user->get('realm_type')
			== Bivio::Auth::RealmType::USER()) {
		    # Invalid user id (deleted?)
		    $state =
			    Bivio::Agent::HTTP::CookieState::INVALID_USER();
		    $user = undef;
		    last;
		}
	    }
	    $state = Bivio::Agent::HTTP::CookieState::OK();
	}
	$state = Bivio::Agent::HTTP::CookieState::NO_DATA() unless $data;
	unless ($state == Bivio::Agent::HTTP::CookieState::OK()) {
	    # If we get here, then there was something pretty wrong.
	    Bivio::IO::Alert->warn($state->get_long_desc);
	    $data = undef;
	}
	$req->put(cookie => $data, cookie_state => $state,
		timezone => $data ? $data->{$_TIMEZONE_FIELD} : undef);
    }
    _trace('state=', $state, '; data=', $data) if $_TRACE;
    return $user;
}

=for html <a name="set"></a>

=head2 set(Bivio::Agent::Request req, Apache::Request r)

Sets the cookie in the header.

=cut

sub set {
    my(undef, $req, $r) = @_;

    # You can set other fields in the cookie in the request.
    my($cookie) = $req->unsafe_get('cookie') || {};

    # Since our cookie is encrypted, we don't need to set "secure".
    # Allows us to track users better (on non-secure portions of the site).
    my($s) = 'Path=/;';
    $s .= " Domain=$_DOMAIN;" if $_DOMAIN;
    $cookie->{$_REMOTE_IP_FIELD} = $r->connection->remote_ip;
    my($user) = Bivio::Agent::Request->get_current->get('auth_user');
    # Ensure user is set to undef if not set
    $cookie->{$_USER_FIELD} = $user ? $user->get('realm_id') : undef;
    _trace('data=', $cookie) if $_TRACE;
    my($cs) = '';
    foreach my $k (sort(keys(%$cookie))) {
	$cs .= $k.$;.$cookie->{$k}.$; if defined($cookie->{$k});
    }
    # remove trailing $;
    chop($cs);
    # encrypt and store as value
    $s = "$_TAG=".$_CIPHER->encrypt_hex($cs).'; '.$s;
    # No expiry means not saved in cookies file on disk
    $r->header_out('Cache-Control', 'no-cache=set-cookie');
    $r->header_out('Set-Cookie', $s);
    return;
}

=for html <a name="set_field"></a>

=head2 static set_field(Bivio::Agent::Request req, string name, string value)

Sets the cookie

=cut

sub set_field {
    my(undef, $req, $name, $value) = @_;
    my($cookie) = $req->unsafe_get('cookie');
    $req->put(cookie => ($cookie = {})) unless $cookie;
    $cookie->{$name} = $value;
    return;
}

=for html <a name="unsafe_get_field"></a>

=head2 unsafe_get_field(Bivio::Agent::Request req, string name) : string

Return the value form the field in the cookie.  May be C<undef>

=cut

sub unsafe_get_field {
    my(undef, $req, $name) = @_;
    my($cookie) = $req->unsafe_get('cookie');
    return $cookie ? $cookie->{$name} : undef;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
