# Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::ReallyLongText;
use strict;
$Bivio::Type::ReallyLongText::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::ReallyLongText::VERSION;

=head1 NAME

Bivio::Type::ReallyLongText - even longer than long text

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Type::ReallyLongText;

=cut

=head1 EXTENDS

L<Bivio::Type::Text>

=cut

use Bivio::Type::Text;
@Bivio::Type::ReallyLongText::ISA = ('Bivio::Type::Text');

=head1 DESCRIPTION

C<Bivio::Type::ReallyLongText>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_width"></a>

=head2 static get_width : int

Returns 100_000.

=cut

sub get_width {
    return 100_000;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
