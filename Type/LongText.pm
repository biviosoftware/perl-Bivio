# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::Type::LongText;
use strict;
$Bivio::Type::LongText::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::LongText - longer (4000 char) version of Text

=head1 SYNOPSIS

    use Bivio::Type::LongText;

=cut

=head1 EXTENDS

L<Bivio::Type::Text>

=cut

use Bivio::Type::Text;
@Bivio::Type::LongText::ISA = ('Bivio::Type::Text');

=head1 DESCRIPTION

C<Bivio::Type::LongText> same as L<Bivio::Type::Text|Bivio::Type::Text>
except 4000 characters.

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_width"></a>

=head2 static get_width : int

Returns 4000.

=cut

sub get_width {
    return 4000;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
