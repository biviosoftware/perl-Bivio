# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Auth::Realm::Proxy;
use strict;
$Bivio::Auth::Realm::Proxy::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Auth::Realm::Proxy - defines a phantom realm which hides underlying realm name

=head1 SYNOPSIS

    use Bivio::Auth::Realm::Proxy;
    Bivio::Auth::Realm::Proxy->new(Bivio::Auth::Realm realm);

=cut

=head1 EXTENDS

L<Bivio::Auth::Realm>

=cut

use Bivio::Auth::Realm;
@Bivio::Auth::Realm::Proxy::ISA = qw(Bivio::Auth::Realm);

=head1 DESCRIPTION

C<Bivio::Auth::Realm::Proxy> defines a realm which hides another
realm.

=cut


=head1 CONSTANTS

=cut

=for html <a name="FIRST_URI_COMPONENT"></a>

=head2 FIRST_URI_COMPONENT : string

Prefix (RealmName) to all proxy realm URIs.

=cut

sub FIRST_URI_COMPONENT {
    return 'pub';
}

#=IMPORTS
use Bivio::IO::Alert;
use Bivio::Die;
# Avoid circular imports
# use Bivio::Agent::Request

#=VARIABLES
my($_URI_PREFIX) = '/'.FIRST_URI_COMPONENT().'/';
my(%_CFG) = (
        ask_candis => 'ask_candis',
        trez_talk => 'trez_talk',
);
my($_MAP);

=head1 FACTORIES

=cut

=for html <a name="from_name"></a>

=head2 static from_name(string proxy_name) : Bivio::Auth::ProxyRealm

Returns this proxy realm from the proxy_name or throws an error.

=cut

sub from_name {
    my($proto, $proxy_name) = @_;
    $_MAP || _initialize();
    Bivio::Die->die('NOT_FOUND',
	    {entity => $proxy_name, class => __PACKAGE__})
		unless defined($proxy_name) && defined($_MAP->{$proxy_name});
    return $_MAP->{$proxy_name};
}

=for html <a name="from_uri"></a>

=head2 static from_uri(string uri) : Bivio::Auth::ProxyRealm

Returns this proxy realm from the uri or throws an error.

=cut

sub from_uri {
    my($proto, $uri) = @_;
    Bivio::IO::Alert->die($uri, ': bad proxy realm uri (TaskId config?)')
		unless $uri =~ m!^${_URI_PREFIX}([^/]+)!o;
    return $proto->from_name($1);
}

=for html <a name="new"></a>

=head2 static new(Bivio::Biz::Model::RealmOwner owner) : Bivio::Auth::Realm::Proxy

Define the realm owned by this particular user.

=cut

sub new {
    my($proto, $owner, $proxy_name) = @_;
    # Fake owner completely, because we don't want to be able
    # to do operations on RealmOwner in proxy realm.  This is mostly
    # a protection right now, because this was added much later in
    # the design after the assumptions about owner were distributed
    # throughout the code.  This should catch any assumptions.
    my($fake_owner) = Bivio::Collection::Attributes->new({
	map {($_, $owner->get($_))} @{$owner->get_keys()}
    });

    # Never display the "real" name to the users.
    # Indicate this is a PROXY.
    $fake_owner->put(
	    name => $proxy_name,
	    realm_type => Bivio::Auth::RealmType::PROXY(),
	   );
    my($self) = &Bivio::Auth::Realm::new($proto, $fake_owner);

    # We override values that are set
    $self->put(
	    _uri => $_URI_PREFIX.$proxy_name,
	    _email => $proxy_name.'@'.$owner->get_request->get('mail_host'),
#TODO: Delete when file server is gone
	    _file => $owner->get('name'),
	   );
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_list"></a>

=head2 static get_list() : array

List of proxy realms

=cut

sub get_list {
    $_MAP || _initialize();
    return values(%$_MAP);
}

#=PRIVATE METHODS

# _initialize()
#
# Initializes $_MAP from %_CFG
#
sub _initialize {
    # Already initialized?
    return if $_MAP;

    $_MAP = {};
    my($req) = Bivio::Agent::Request->new();
    foreach my $proxy_name (keys(%_CFG)) {
	my($o) = Bivio::Biz::Model::RealmOwner->new($req);
	Bivio::IO::Alert->die($_CFG{$proxy_name}, ': realm_owner not found')
		    unless $o->unauth_load(name => $_CFG{$proxy_name});
	my($r) = __PACKAGE__->new($o, $proxy_name);
	$_MAP->{$proxy_name} = $r;
    }
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
