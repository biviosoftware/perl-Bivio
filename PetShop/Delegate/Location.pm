# Copyright (c) 2004 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Delegate::Location;
use strict;
$Bivio::PetShop::Delegate::Location::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Delegate::Location::VERSION;

=head1 NAME

Bivio::PetShop::Delegate::Location - Address/Email/Phone location

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Delegate::Location;

=cut

=head1 EXTENDS

L<Bivio::Delegate>

=cut

use Bivio::Delegate;
@Bivio::PetShop::Delegate::Location::ISA = ('Bivio::Delegate');

=head1 DESCRIPTION

C<Bivio::PetShop::Delegate::Location>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_delegate_info"></a>

=head2 get_delegate_info() : array_ref

Returns PRIMARY, BILL_TO and SHIP_TO.

=cut

sub get_delegate_info {
    return [
	PRIMARY => [1],
        BILL_TO => [2],
        SHIP_TO => [3],
    ];
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2004 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
