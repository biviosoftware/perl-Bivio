# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Auth::Realm::General;
use strict;
$Bivio::Auth::Realm::General::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Auth::Realm::General::VERSION;

=head1 NAME

Bivio::Auth::Realm::General - defines the realm without an owner

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Auth::Realm::General;

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

#=IMPORTS
use Bivio::IO::Config;

#=VARIABLES
my($_SELF);

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Auth::Realm::General

=cut

sub new {
    my($proto) = @_;
    return Bivio::Auth::Realm::new($proto);
}

=head1 METHODS

=cut

=for html <a name="get_instance"></a>

=head2 static get_instance() : Bivio::Auth::Realm::General

Returns the singleton instance of the general realm.

=cut

sub get_instance {
    my($proto) = @_;
    $_SELF = $proto->new unless $_SELF;
    return $_SELF;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
