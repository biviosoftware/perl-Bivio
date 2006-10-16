# Copyright (c) 2001 bivio Software, Inc.  All Rights reserved.
# $Id$
package Bivio::Type::ECPaymentStatusSet;
use strict;
$Bivio::Type::ECPaymentStatusSet::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::ECPaymentStatusSet::VERSION;

=head1 NAME

Bivio::Type::ECPaymentStatusSet - set of ECPaymentStatus

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Type::ECPaymentStatusSet;

=cut

=head1 EXTENDS

L<Bivio::Type::EnumSet>

=cut

use Bivio::Type::EnumSet;
@Bivio::Type::ECPaymentStatusSet::ISA = ('Bivio::Type::EnumSet');

=head1 DESCRIPTION

C<Bivio::Type::ECPaymentStatusSet> is a set of
L<Bivio::Type::ECPaymentStatus|Bivio::Type::ECPaymentStatus>.

=cut

#=IMPORTS
use Bivio::Type::ECPaymentStatus;

#=VARIABLES
__PACKAGE__->initialize;

=head1 METHODS

=cut

=for html <a name="get_enum_type"></a>

=head2 get_enum_type() : Bivio::Type::Enum

Returns L<Bivio::Auth::Permission|Bivio::Auth::Permission>.

=cut

sub get_enum_type {
    return 'Bivio::Type::ECPaymentStatus';
}

=for html <a name="get_width"></a>

=head2 get_width() : int

Returns 4 (32 bits).

=cut

sub get_width {
    return 4;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Software, Inc.  All Rights reserved.

=head1 VERSION

$Id$

=cut

1;
