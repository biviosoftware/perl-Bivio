# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type::Name;
use strict;
$Bivio::Type::Name::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::Name - holds a simple name, login id, account number, etc.

=head1 SYNOPSIS

    use Bivio::Type::Name;

=cut

=head1 EXTENDS

L<Bivio::Type::String>

=cut

use Bivio::Type::String;
@Bivio::Type::Name::ISA = qw(Bivio::Type::String);

=head1 DESCRIPTION

C<Bivio::Type::Name> defines a simple name, e.g. first name,
last name, account identifier, and login name.  If you want
a compound name, use L<Bivio::Type::Line|Bivio::Type::Line>.

=cut

=head1 CONSTANTS

=cut

=for html <a name="WIDTH"></a>

=head2 WIDTH : int

Returns 30.

=cut

sub WIDTH {
    return 30;
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
