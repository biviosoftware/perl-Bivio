# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Auth::Realm::AnyUser;
use strict;
$Bivio::Auth::Realm::AnyUser::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Auth::Realm::AnyUser - defines the realm which any user can access

=head1 SYNOPSIS

    use Bivio::Auth::Realm::AnyUser;
    Bivio::Auth::Realm::AnyUser->new();

=cut

=head1 EXTENDS

L<Bivio::Auth::Realm>

=cut

use Bivio::Auth::Realm;
@Bivio::Auth::Realm::AnyUser::ISA = ('Bivio::Auth::Realm');

=head1 DESCRIPTION

C<Bivio::Auth::Realm::AnyUser> defines the realm in which any registered
user can have access.  This realm may be cached statically as it
doesn't have an owner.

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::Agent::TaskId;
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my(%_TASK_ID_TO_ROLE) = map {
    my($t, $r) = split(/:/);
    (Bivio::Agent::TaskId->$t(), Bivio::Auth::Role->$r())
} (
    'SETUP_CLUB_CREATE:USER',
    'SETUP_CLUB_EDIT:USER',
);

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Auth::Realm::AnyUser

=cut

sub new {
    my($proto) = @_;
    return &Bivio::Auth::Realm::new($proto, \%_TASK_ID_TO_ROLE);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
