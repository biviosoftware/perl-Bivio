# Copyright (c) 2004 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::Dollar;
use strict;
$Bivio::Type::Dollar::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::Dollar::VERSION;

=head1 NAME

Bivio::Type::Dollar - Amount rounded to cents

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Type::Dollar;

=cut

=head1 EXTENDS

L<Bivio::Type::Amount>

=cut

use Bivio::Type::Amount;
@Bivio::Type::Dollar::ISA = ('Bivio::Type::Amount');

=head1 DESCRIPTION

C<Bivio::Type::Dollar>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_decimals"></a>

=head2 static get_decimals : int

Returns 2.

=cut

sub get_decimals {
    return 2;
}

=for html <a name="get_max"></a>

=head2 static get_max : string

Returns '9999999999999.99'.

=cut

sub get_max {
    return '9999999999999.99';
}

=for html <a name="get_min"></a>

=head2 static get_min : string

Returns '-9999999999999.99'.

=cut

sub get_min {
    return '-9999999999999.99';
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2004 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
