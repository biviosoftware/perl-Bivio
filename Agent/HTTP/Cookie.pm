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
We send a single value ("D") back to the user.  (Initially, I
tried to send a version along with this, but IE doesn't seem to
return multiple values.)
The value is encrypted or url-encoded depending on the configuration.

The contents of the D-value is returned as a hash_ref.  It contains
a "x" (expires) field which is managed by this module.

Cookie fields are kept short as there is limited storage space on
the client.  The following field names are currently in use:

=over 4

=item i

ip address of client (C<$r-E<gt>connection->remote_ip>)

=item u

login id (realm_id) of the authenticated user.

=item x

the time the cookie expires in seconds

=back

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::Agent::HTTP::CookieState;
use Bivio::IO::Config;
use Bivio::Util;
use Crypt::CBC;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_USER_FIELD) = 'u';
my($_EXPIRES_FIELD) = 'x';
my($_REMOTE_IP_FIELD) = 'i';
my($_DOMAIN) = undef;
my($_CIPHER) = undef;
my($_EXPIRE_SECONDS) = 3600;
Bivio::IO::Config->register({
    domain => $_DOMAIN,
    key => Bivio::IO::Config->REQUIRED,
    expire_seconds => $_EXPIRE_SECONDS,
});

=head1 METHODS

=cut

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item domain : string [undef]

If defined, maps the cookie domain to be used in cookies.  Otherwise,
cookies are not returned with a domain (normal for testing).

=item expire_seconds : int [3600]

How long before the cookie expires.  The cookie is re-invigorated on
each request, so this is the maximum time between requests.

=item key : string (required)

If defined, the content of the cookie will be encrypted.  Otherwise,
the cookie will be sent in plain text (url encoded).

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    Carp::croak("$cfg->{domain}: domain must have two dots in it")
		unless !$cfg->{domain} || $cfg->{domain} =~ /\..*\./;
    $_DOMAIN = $cfg->{domain};
    $_EXPIRE_SECONDS = $cfg->{expire_seconds};
    $_CIPHER = $cfg->{key} ? Crypt::CBC->new($cfg->{key}, 'IDEA') : undef;
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
    my($state) = Bivio::Agent::HTTP::CookieState::OK();
    my($data, $user);
    unless (defined($cookie)) {
	# No warning here, because fairly normal case
	$state = Bivio::Agent::HTTP::CookieState::NOT_SET();
    }
    else {
	# Our cookies don't have ';' in them.  If someone sends a cookie
	# back with ';' in it, well, it won't parse correctly
	foreach my $f (split(/\s*;\s*/, $cookie)) {
	    my($k, $v) = split(/\s*=\s*/, $f, 2);
	    $k = uc($k);
	    if ($k eq 'D') {
		my($s) = $_CIPHER ? $_CIPHER->decrypt_hex($v) :
			Bivio::Util::unescape_uri($v);
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
		unless ($data->{$_EXPIRES_FIELD}) {
		    $state = Bivio::Agent::HTTP::CookieState::NO_EXPIRES();
		    last;
		}
		# We try to get the user now, because we know basically
		# that everything in the cookie is ok.  It may be expired,
		# but if so, we'll set unauth_user on request so we need
		# a user to set to.
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
		# Only expire the cookie if there is a user
		if (time > $data->{$_EXPIRES_FIELD} && $user) {
		    # Cookie expired, but store the wouldbe user in the
		    # request so LoginForm can fill it in later.
		    $req->put(unauth_user => $user);
		    $user = undef;
		    $state = Bivio::Agent::HTTP::CookieState::EXPIRED();
		    last;
		}
		# $data is set and if version is set, $state will be ok
	    }
	    else {
		$state = Bivio::Agent::HTTP::CookieState::INVALID();
		last;
	    }
	}
	$state = Bivio::Agent::HTTP::CookieState::NO_DATA() unless $data;
	unless ($state == Bivio::Agent::HTTP::CookieState::OK()) {
	    # If we get here, then there was something pretty wrong
	    # except in the case of expires, but even then that should be rare.
	    warn($state->get_long_desc);
	    $data = undef;
	}
    }
    _trace('state=', $state, '; data=', $data) if $_TRACE;
    return $user;
}

=for html <a name="set"></a>

=head2 set(Apache::Request r)

Sets the cookie in the header.

=cut

sub set {
    my(undef, $r) = @_;
    # This code is written generally, i.e. you could set other fields.
    # Right now, the cookie is created here.
    my($cookie) = {};

    # Since our cookie is encrypted, we don't need to set "secure".
    # Allows us to track users better (on non-secure portions of the site).
    my($s) = 'Path=/;';
    $s .= " Domain=$_DOMAIN;" if $_DOMAIN;
    $cookie->{$_EXPIRES_FIELD} = time + $_EXPIRE_SECONDS;
    $cookie->{$_REMOTE_IP_FIELD} = $r->connection->remote_ip;
    my($user) = Bivio::Agent::Request->get_current->get('auth_user');
    $cookie->{$_USER_FIELD} = $user->get('realm_id') if $user;
    _trace('data=', $cookie) if $_TRACE;
    my($cs) = '';
    foreach my $k (sort(keys(%$cookie))) {
	$cs .= $k.$;.$cookie->{$k}.$; if defined($cookie->{$k});
    }
    # remove trailing $;
    chop($cs);
    # encrypt and store as value
    $s = 'D='
	    .($_CIPHER ? $_CIPHER->encrypt_hex($cs) :
		    Bivio::Util::escape_uri($cs)).'; '.$s;
    # No expiry means not saved in cookies file on disk
    $r->header_out('Cache-Control', 'no-cache=set-cookie');
    $r->header_out('Set-Cookie', $s);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
