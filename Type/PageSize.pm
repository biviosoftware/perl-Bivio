# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::Type::PageSize;
use strict;
$Bivio::Type::PageSize::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::PageSize - number of lines on a page for ListModel queries

=head1 SYNOPSIS

    use Bivio::Type::PageSize;
    Bivio::Type::PageSize->new();

=cut

=head1 EXTENDS

L<Bivio::Type::Integer>

=cut

use Bivio::Type::Integer;
@Bivio::Type::PageSize::ISA = ('Bivio::Type::Integer');

=head1 DESCRIPTION

C<Bivio::Type::PageSize> is the number of lines on a page for
ListModel queries.  It is a user preference.

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_default"></a>

=head2 get_default() : int

Returns 15.

=cut

sub get_default {
    return 15;
}

=for html <a name="get_max"></a>

=head2 get_max() : integer

Returns 500.

=cut

sub get_max {
    return 500;
}

=for html <a name="get_min"></a>

=head2 get_min() : int

Returns 5.

=cut

sub get_min {
    return 5;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
