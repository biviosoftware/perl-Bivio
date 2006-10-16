# Copyright (c) 1999,2000 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::Location;
use strict;
$Bivio::Type::Location::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::Location::VERSION;

=head1 NAME

Bivio::Type::Location - identifies a physical location of address, phone, email

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Type::Location;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>;

=cut

use Bivio::Type::Enum;
@Bivio::Type::Location::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Type::Location> describes the physical location where an
address, phone, or email resides.

It can be assumed C<HOME> is defined.

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile(
    Bivio::IO::ClassLoader->delegate_require_info(__PACKAGE__));

sub get_default {
    return shift->from_int(1);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
