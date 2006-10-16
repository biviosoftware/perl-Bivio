# Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::Name;
use strict;
$Bivio::Type::Name::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::Name::VERSION;

=head1 NAME

Bivio::Type::Name - holds a simple name, login id, account number, etc.

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Type::Name;

=cut

=head1 EXTENDS

L<Bivio::Type::Line>

=cut

use Bivio::Type::Line;
@Bivio::Type::Name::ISA = ('Bivio::Type::Line');

=head1 DESCRIPTION

C<Bivio::Type::Name> defines a simple name, e.g. first name,
last name, account identifier, and login name.  If you want
a compound name, use L<Bivio::Type::Line|Bivio::Type::Line>.

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_width"></a>

=head2 static get_width : int

Returns 30.

=cut

sub get_width {
    return 30;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
