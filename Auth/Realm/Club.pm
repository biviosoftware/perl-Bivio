# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Auth::Realm::Club;
use strict;
$Bivio::Auth::Realm::Club::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Auth::Realm::Club::VERSION;

=head1 NAME

Bivio::Auth::Realm::Club - defines the realm owned by a particular club

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Auth::Realm::Club;
    Bivio::Auth::Realm::Club->new(Bivio::Biz::Model::Club owner);

=cut

=head1 EXTENDS

L<Bivio::Auth::Realm>

=cut

use Bivio::Auth::Realm;
@Bivio::Auth::Realm::Club::ISA = qw(Bivio::Auth::Realm);

=head1 DESCRIPTION

C<Bivio::Auth::Realm::Club> defines the realm owned by a particular
L<Bivio::Biz::Model::Club|Bivio::Biz::Model::Club>.

=cut

#=IMPORTS

#=VARIABLES

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Biz::Model::RealmOwner owner) : Bivio::Auth::Realm::Club

Define the realm owned by this particular club.

=cut

sub new {
    my($proto, $owner) = @_;
    return &Bivio::Auth::Realm::new($proto, $owner);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
