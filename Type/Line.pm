# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type::Line;
use strict;
$Bivio::Type::Line::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::Line - holds a line of text or full name

=head1 SYNOPSIS

    use Bivio::Type::Line;

=cut

=head1 EXTENDS

L<Bivio::Type::String>

=cut

use Bivio::Type::String;
@Bivio::Type::Line::ISA = qw(Bivio::Type::String);

=head1 DESCRIPTION

C<Bivio::Type::Line> defines a compound name or long line of text, e.g.
a person's full name, an e-mail address, and an account name.
If you want
a simple name, e.g.
first name, use L<Bivio::Type::Name|Bivio::Type::Name>.

=cut

=head1 CONSTANTS

=cut

=for html <a name="WIDTH"></a>

=head2 WIDTH : int

Returns 100.

=cut

sub WIDTH {
    return 100;
}

#=IMPORTS

#=VARIABLES

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
