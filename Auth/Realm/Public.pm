# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Auth::Realm::Public;
use strict;
$Bivio::Auth::Realm::Public::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Auth::Realm::Public - defines the realm which anyone can access

=head1 SYNOPSIS

    use Bivio::Auth::Realm::Public;
    Bivio::Auth::Realm::Public->new();

=cut

=head1 EXTENDS

L<Bivio::Auth::Realm>

=cut

use Bivio::Auth::Realm;
@Bivio::Auth::Realm::Public::ISA = ('Bivio::Auth::Realm');

=head1 DESCRIPTION

C<Bivio::Auth::Realm::Public> defines the "default" realm, i.e.
access by anyone.  This realm may be cached statically as it
doesn't have an owner.

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::Auth::Role;
use Bivio::Agent::TaskId;
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Auth::Realm::Public

=cut

sub new {
    my($proto) = @_;
    return &Bivio::Auth::Realm::new($proto);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
