# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Agent::Cookie;
use strict;
$Bivio::PetShop::Agent::Cookie::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Agent::Cookie::VERSION;

=head1 NAME

Bivio::PetShop::Agent::Cookie - Pet Shop HTTP Cookie management

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Agent::Cookie;

=cut

=head1 EXTENDS

L<Bivio::Collection::Attributes>

=cut

use Bivio::Collection::Attributes;
@Bivio::PetShop::Agent::Cookie::ISA = ('Bivio::Collection::Attributes');

=head1 DESCRIPTION

C<Bivio::PetShop::Agent::Cookie> manages cookies arriving via HTTP and returns
cookies to the user.

Cookies are persistent in this demo.  A real shop probably wouldn't always
"save password", but for our purposes this simplifies the implementation.

=cut


#=IMPORTS
use Bivio::IO::Config;
use Bivio::IO::Trace;
use Bivio::Type::Secret;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
# This field is used only locally.  See header_out()
my($_MODIFIED_FIELD) = '_modified';
# This field should always be returned with the cookie
my($_OK_FIELD) = 'ok';
my($_PERSISTENT_TAG) = 'P';
my($_SEP) = "\036";
my($_DOMAIN) = undef;
Bivio::IO::Config->register({
    domain => $_DOMAIN,
});

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Agent::Request req, Apache::Request r) : Bivio::PetShop::Agent::Cookie

Creates a new cookie processor.

=cut

sub new {
    my($proto, $req, $r) = @_;
    return Bivio::Collection::Attributes::new($proto, {})
	    unless $req->get('Bivio::Type::UserAgent')->is_browser();
    return Bivio::Collection::Attributes::new($proto,
	    _parse($r->header_in('Cookie') || ''));
}

=head1 METHODS

=cut

=for html <a name="assert_is_ok"></a>

=head2 static assert_is_ok(Bivio::Agent::Request req)

Check to see if cookie is enabled.

=cut

sub assert_is_ok {
    my($proto, $req) = @_;
    return unless $req->get('Bivio::Type::UserAgent')->is_browser;

    my($self) = $req->get('cookie');
    # Make sure browser has both cookies.
    return if $self->unsafe_get($_OK_FIELD);

    $req->throw_die('MISSING_COOKIES', {
	client_addr => $req->get('client_addr'),
	ok_field => $self->unsafe_get($_OK_FIELD),
    });
    # DOES NOT RETURN
}

=for html <a name="delete"></a>

=head2 delete(string key, ...)

Removes the named attribute(s) from the map.  They needn't exist.

=cut

sub delete {
    my($self) = shift;
    _trace(\@_) if $_TRACE;
    my($res) = $self->SUPER::delete(@_);
    $self->put($_MODIFIED_FIELD => 1);
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

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_DOMAIN = $cfg->{domain};
    return;
}

=for html <a name="header_out"></a>

=head2 header_out(Apache::Request r, Bivio::Agent::Request req) : boolean

Writes the header.  If the cookie isn't written (not modified), returns
false.

=cut

sub header_out {
    my($self, $r, $req) = @_;
    my($fields) = $self->internal_get;

    # Only set if a modified and a browser.
    return 0 unless $fields->{$_MODIFIED_FIELD}
	    && $req->get('Bivio::Type::UserAgent')->is_browser;

    # Set the ok field so we can see if the cookie comes back
    $fields->{$_OK_FIELD} = 1;

    # Since our fields are encrypted, we don't need to return a "secure"
    # cookie.  Allows us to track users better (on non-secure portions of the
    # site).
    my($p) = '; path=/';
    $p .= "; domain=$_DOMAIN" if $_DOMAIN;
    my($v) = $p;

    # Yahoo uses this magic date to mean forever.  We use it, too.
    $p .= '; expires=Thu, 15 Apr 2010 20:00:00 GMT';

    _trace('data=', $fields) if $_TRACE;

    my($clear_text) = '';
    while (my($k, $v) = each(%$fields)) {
	# Skip internal fields ($_MODIFIED_FIELD begins with '_')
	next if $k =~ /^_/;

	# Only append the field if it is defined
	$clear_text .= $k.$_SEP.$v.$_SEP if defined($v);
    }
    # Remove last $_SEP
    chop($clear_text);

    my($value) = $_PERSISTENT_TAG
	    .'='.Bivio::Type::Secret->encrypt_hex($clear_text).$p;
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
    _trace(\@_) if $_TRACE;
    return $self->SUPER::put(@_, $_MODIFIED_FIELD, 1);
}

#=PRIVATE METHODS

# _parse(string cookie) : hash_ref
#
# Parses the attributes out of the cookie.  If the 
#
sub _parse {
    my($cookie) = @_;
    _trace($cookie) if $_TRACE;
    my($values) = {};

    foreach my $f (split(/\s*[;,]\s*/, $cookie)) {
	my($k, $v) = split(/\s*=\s*/, $f, 2);

	# We ignore all other parts of the cookie
	unless (defined($k) && defined($v)) {
	    _trace($k, ': ignoring other element') if $_TRACE;
	    next;
	}

	# Did we get our tag back?
	$k = uc($k);
	unless ($k eq $_PERSISTENT_TAG) {
	    _trace('tag from another server or old tag: ', $k) if $_TRACE;
	    next;
	}

	my($s) = Bivio::Type::Secret->decrypt_hex($v);
	unless ($s) {
	    # Error decoding.  Warning already output by Base64.
	    _trace('unable to decode: ', $v) if $_TRACE;
	    # We know nothing about the validity of the cookie, so we start
	    # from scratch.
	    return {$_OK_FIELD => 0, $_MODIFIED_FIELD => 1};
	}

	my(@v) = split(/$_SEP/o, $s);
	_trace('data=', \@v) if $_TRACE;
	# Make sure we have an even number of elements and then convert to hash
	push(@v, '') if int(@v) % 2;
	my(%v) = @v;

	# Copy over all the field values; they will be parsed by the handlers
	while (my($k, $v) = each(%v)) {
	    $values->{$k} = $v;
	}
    }
    return $values;
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
