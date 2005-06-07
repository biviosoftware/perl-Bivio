# Copyright (c) 2005 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Delegate::Role;
use strict;
$Bivio::PetShop::Delegate::Role::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Delegate::Role::VERSION;

=head1 NAME

Bivio::PetShop::Delegate::Role - roles for the PetShop application

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Delegate::Role;

=cut

=head1 EXTENDS

L<Bivio::Delegate::Role>

=cut

use Bivio::Delegate::Role;
@Bivio::PetShop::Delegate::Role::ISA = ('Bivio::Delegate::Role');

=head1 DESCRIPTION

C<Bivio::PetShop::Delegate::Role>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_delegate_info"></a>

=head2 get_delegate_info() : array_ref

Return test roles.

=cut

sub get_delegate_info {
    my($proto) = @_;
    return [
	@{$proto->SUPER::get_delegate_info},
	TEST_ROLE1 => [21],
	TEST_ROLE2 => [22],
    ];
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
