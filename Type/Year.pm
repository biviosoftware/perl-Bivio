# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Type::Year;
use strict;
$Bivio::Type::Year::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::Year::VERSION;

=head1 NAME

Bivio::Type::Year - date year field type

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Type::Year;
    Bivio::Type::Year->new();

=cut

=head1 EXTENDS

L<Bivio::Type::Integer>

=cut

use Bivio::Type::Integer;
@Bivio::Type::Year::ISA = ('Bivio::Type::Integer');

=head1 DESCRIPTION

C<Bivio::Type::Year> date year field type

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="get_max"></a>

=head2 static get_max : any

Returns 9999.

=cut

sub get_max {
    return '9999';
}

=for html <a name="get_min"></a>

=head2 static get_min : any

Returns 0.

=cut

sub get_min {
    return 0;
}

=for html <a name="get_width"></a>

=head2 static get_width : int

Returns 4.

=cut

sub get_width {
    return 4;
}


#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
