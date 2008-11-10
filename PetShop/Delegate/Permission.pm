# Copyright (c) 2004 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Delegate::Permission;
use strict;
$Bivio::PetShop::Delegate::Permission::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Delegate::Permission::VERSION;

=head1 NAME

Bivio::PetShop::Delegate::Permission - unit test permissions

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Delegate::Permission;

=cut

use Bivio::Delegate::SimplePermission;
@Bivio::PetShop::Delegate::Permission::ISA = ('Bivio::Delegate::SimplePermission');

=head1 DESCRIPTION

C<Bivio::PetShop::Delegate::Permission>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_delegate_info"></a>

=head2 get_delegate_info() : array_ref

Returns the application permissions.

=cut

sub get_delegate_info {
    my($proto) = @_;
    return [
	@{$proto->SUPER::get_delegate_info},
	TEST_PERMISSION1 => [51],
	TEST_PERMISSION2 => [52],
    ];
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2004 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
