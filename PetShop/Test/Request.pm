# Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Test::Request;
use strict;
$Bivio::PetShop::Test::Request::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Test::Request::VERSION;

=head1 NAME

Bivio::PetShop::Test::Request - ensures operating in PetShop facade

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Test::Request;

=cut

=head1 EXTENDS

L<Bivio::Test::Request>

=cut

use Bivio::Test::Request;
@Bivio::PetShop::Test::Request::ISA = ('Bivio::Test::Request');

=head1 DESCRIPTION

C<Bivio::PetShop::Test::Request> will ensure the PetShop facade is
setup.

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="setup_facade"></a>

=head2 setup_facade() : self

Returns self but asserts facade is PetShop.

=cut

sub setup_facade {
    my($self) = shift->SUPER::setup_facade(@_);
    die('must be executed in PetShop environment')
	unless $self->get('Bivio::UI::Facade')->simple_package_name
	    eq 'PetShop';
    return $self;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
