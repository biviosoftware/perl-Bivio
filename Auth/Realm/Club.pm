# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Auth::Realm::Club;
use strict;
$Bivio::Auth::Realm::Club::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Auth::Realm::Club - defines the realm owned by a particular user

=head1 SYNOPSIS

    use Bivio::Auth::Realm::Club;
    Bivio::Auth::Realm::Club->new(Bivio::Biz::PropertyModel::Club owner);

=cut

=head1 EXTENDS

L<Bivio::Auth::Realm>

=cut

use Bivio::Auth::Realm;
@Bivio::Auth::Realm::Club::ISA = qw(Bivio::Auth::Realm);

=head1 DESCRIPTION

C<Bivio::Auth::Realm::Club> defines the realm owned by a particular
L<Bivio::Biz::PropertyModel::Club|Bivio::Biz::PropertyModel::Club>.

=cut

#=IMPORTS
use Bivio::Biz::PropertyModel::Club;
use Bivio::Agent::TaskId;
use Bivio::Auth::Role;

#=VARIABLES

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Biz::PropertyModel::RealmOwner owner) : Bivio::Auth::Realm::Club

Define the realm owned by this particular user.

=cut

sub new {
    my($proto, $owner) = @_;
    return &Bivio::Auth::Realm::new($proto, $owner);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
