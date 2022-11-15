# Copyright (c) 2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Delegate::TypeError;
use strict;
=head1 NAME

Bivio::PetShop::Delegate::TypeError - Pet Shop type errors

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Delegate::TypeError;

=cut

use Bivio::Delegate::SimpleTypeError;
@Bivio::PetShop::Delegate::TypeError::ISA = ('Bivio::Delegate::SimpleTypeError');

=head1 DESCRIPTION

C<Bivio::PetShop::Delegate::TypeError>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_delegate_info"></a>

=head2 static get_delegate_info() : array_ref

Returns the task declarations.

=cut

sub get_delegate_info {
    my($proto) = @_;
    return [
    @{$proto->SUPER::get_delegate_info},
    TOTAL_EXCEEDS_PRECISION => [
        501,
        undef,
        'The cart total exceeds the allowed precision.',
    ],
];
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
