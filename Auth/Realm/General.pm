# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Auth::Realm::General;
use strict;
$Bivio::Auth::Realm::General::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Auth::Realm::General - defines the realm without an owner

=head1 SYNOPSIS

    use Bivio::Auth::Realm::General;
    Bivio::Auth::Realm::General->new();

=cut

=head1 EXTENDS

L<Bivio::Auth::Realm>

=cut

use Bivio::Auth::Realm;
@Bivio::Auth::Realm::General::ISA = ('Bivio::Auth::Realm');

=head1 DESCRIPTION

C<Bivio::Auth::Realm::General> defines the "default" realm, i.e.
the one without a specific owner.

=cut

=head1 CONSTANTS

=cut

#=IMPORTS

#=VARIABLES

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Auth::Realm::General

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
