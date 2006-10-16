# Copyright (c) 2004 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Delegate::ECService;
use strict;
$Bivio::PetShop::Delegate::ECService::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Delegate::ECService::VERSION;

=head1 NAME

Bivio::PetShop::Delegate::ECService - payment service

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Delegate::ECService;

=cut

=head1 EXTENDS

L<Bivio::Delegate>

=cut

use Bivio::Delegate;
@Bivio::PetShop::Delegate::ECService::ISA = ('Bivio::Delegate');

=head1 DESCRIPTION

C<Bivio::PetShop::Delegate::ECService>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_delegate_info"></a>

=head2 static get_delegate_info() : array_ref

Returns the ECService declarations.

=cut

sub get_delegate_info {
    my($proto) = @_;
    return [
        ANIMAL => [1],
    ];
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2004 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
