# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Auth::Realm::User;
use strict;
$Bivio::Auth::Realm::User::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Auth::Realm::User - defines the realm owned by a particular user

=head1 SYNOPSIS

    use Bivio::Auth::Realm::User;
    Bivio::Auth::Realm::User->new(Bivio::Biz::Model::User owner);

=cut

=head1 EXTENDS

L<Bivio::Auth::Realm>

=cut

use Bivio::Auth::Realm;
@Bivio::Auth::Realm::User::ISA = qw(Bivio::Auth::Realm);

=head1 DESCRIPTION

C<Bivio::Auth::Realm::User> defines the realm owned by a particular
L<Bivio::Biz::Model::User|Bivio::Biz::Model::User>.

=cut

#=IMPORTS
use Bivio::Biz::Model::User;
use Bivio::Agent::TaskId;
use Bivio::Auth::Role;

#=VARIABLES

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Biz::Model::RealmOwner owner) : Bivio::Auth::Realm::User

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
