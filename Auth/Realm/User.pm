# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Auth::Realm::User;
use strict;
$Bivio::Auth::Realm::User::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Auth::Realm::User::VERSION;

=head1 NAME

Bivio::Auth::Realm::User - defines the realm owned by a particular user

=head1 RELEASE SCOPE

bOP

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

Copyright (c) 1999-2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
