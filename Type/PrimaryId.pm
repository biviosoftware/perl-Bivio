# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type::PrimaryId;
use strict;
$Bivio::Type::PrimaryId::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::PrimaryId - describes the numeric primary (object) id

=head1 SYNOPSIS

    use Bivio::Type::PrimaryId;

=cut

=head1 EXTENDS

L<Bivio::Type::Number>

=cut

use Bivio::Type::Number;
@Bivio::Type::PrimaryId::ISA = qw(Bivio::Type::Number);

=head1 DESCRIPTION

C<Bivio::Type::PrimaryId> is a number which uniquely identifies a
row in certain tables.  It is the one and only primary key for those
tables.

All C<PrimaryId> values are unique within a given "universe".  PrimaryIds are
"structured", but you should not depend on this structure.  The purpose of the
structure is to allow for easy horizontal and vertical partitioning.  The lower
five digits identify the table and a site.  This leaves 13 digits for
the rows.  By using the lower digits, we avoid
large numbers until we have large numbers of users and we can expand the
space without having to change the numbering scheme, or all tables.
The decision on the number
of digits for the site and the number of digits for the type has yet to be
made.  Since we have only one site and many types, the lowest digits identify
the type.  See F<sql/societas/sequences.sql> for a more complete discussion.

=cut

=head1 CONSTANTS

=cut

=for html <a name="CAN_BE_NEGATIVE"></a>

=head2 CAN_BE_NEGATIVE : boolean

Returns false.

=cut

sub CAN_BE_NEGATIVE {
    return 0;
}

=for html <a name="CAN_BE_POSITIVE"></a>

=head2 CAN_BE_POSITIVE : boolean

Returns true.

=cut

sub CAN_BE_POSITIVE {
    return 1;
}

=for html <a name="CAN_BE_ZERO"></a>

=head2 CAN_BE_ZERO : boolean

Returns false.

=cut

sub CAN_BE_ZERO {
    return 0;
}

=for html <a name="DECIMALS"></a>

=head2 DECIMALS : int

Returns 0.

=cut

sub DECIMALS {
    return 0;
}

=for html <a name="MAX"></a>

=head2 MAX : string

Returns '999999999999999999'.

=cut

sub MAX {
    return '999999999999999999';
}

=for html <a name="MIN"></a>

=head2 MIN : string

Returns '100001'.

=cut

sub MIN {
    return '100001';
}

=for html <a name="PRECISION"></a>

=head2 abstract PRECISION : int

Returns 18.

=cut

sub PRECISION {
    return 18;
}

=for html <a name="WIDTH"></a>

=head2 WIDTH : int

Returns 18.

=cut

sub WIDTH {
    return 18;
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
