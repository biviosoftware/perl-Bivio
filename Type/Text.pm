# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Type::Text;
use strict;
$Bivio::Type::Text::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::Text::VERSION;

=head1 NAME

Bivio::Type::Text - holds the largest indexable text string

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Type::Text;

=cut

=head1 EXTENDS

L<Bivio::Type::String>

=cut

use Bivio::Type::String;
@Bivio::Type::Text::ISA = ('Bivio::Type::String');

=head1 DESCRIPTION

C<Bivio::Type::Text> defines a complex text string to be stored
in the database, e.g. a remark or a URL.  This is the "maximum"
size string we allow in the database for our purposes.

=cut

#=IMPORTS
use Bivio::TypeError;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_width"></a>

=head2 static get_width : int

Returns 500.

=cut

sub get_width {
    return 500;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
