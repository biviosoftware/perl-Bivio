# Copyright (c) 2005 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::Text64K;
use strict;
$Bivio::Type::Text64K::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::Text64K::VERSION;

=head1 NAME

Bivio::Type::Text64K - text with a 64K limit

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Type::Text64K;

=cut

=head1 EXTENDS

L<Bivio::Type::Text>

=cut

use Bivio::Type::Text;
@Bivio::Type::Text64K::ISA = ('Bivio::Type::Text');

=head1 DESCRIPTION

C<Bivio::Type::Text64K>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_width"></a>

=head2 static get_width : int

Returns 64K.

=cut

sub get_width {
    return 64 * 1024;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
