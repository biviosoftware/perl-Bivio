# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::TypeError;
use strict;
$Bivio::PetShop::TypeError::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::TypeError::VERSION;

=head1 NAME

Bivio::PetShop::TypeError - Pet Shop type errors

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::TypeError;

=cut

use Bivio::Delegate::SimpleTypeError;
@Bivio::PetShop::TypeError::ISA = ('Bivio::Delegate::SimpleTypeError');

=head1 DESCRIPTION

C<Bivio::PetShop::TypeError>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

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

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
