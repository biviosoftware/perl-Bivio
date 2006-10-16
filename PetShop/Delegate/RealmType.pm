# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Delegate::RealmType;
use strict;
$Bivio::PetShop::Delegate::RealmType::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Delegate::RealmType::VERSION;

=head1 NAME

Bivio::PetShop::Delegate::RealmType - PetShop realm types

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Delegate::RealmType;

=cut

=head1 EXTENDS

L<Bivio::Delegate::RealmType>

=cut

use Bivio::Delegate::RealmType;
@Bivio::PetShop::Delegate::RealmType::ISA = ('Bivio::Delegate::RealmType');

=head1 DESCRIPTION

C<Bivio::PetShop::Delegate::RealmType>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_delegate_info"></a>

=head2 get_delegate_info() : array_ref

Returns petshop realms.

=cut

sub get_delegate_info {
    my($proto) = @_;
    return [
        @{$proto->SUPER::get_delegate_info},
        ORDER => [
            20,
            undef,
            'access to an order',
        ],
    ];
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
