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

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="can_be_negative"></a>

=head2 static can_be_negative : boolean

Returns false.

=cut

sub can_be_negative {
    return 0;
}

=for html <a name="can_be_positive"></a>

=head2 static can_be_positive : boolean

Returns true.

=cut

sub can_be_positive {
    return 1;
}

=for html <a name="can_be_zero"></a>

=head2 static can_be_zero : boolean

Returns false.

=cut

sub can_be_zero {
    return 0;
}

=for html <a name="get_decimals"></a>

=head2 static get_decimals : int

Returns 0.

=cut

sub get_decimals {
    return 0;
}

=for html <a name="get_max"></a>

=head2 static get_max : string

Returns '999999999999999999'.

=cut

sub get_max {
    return '999999999999999999';
}

=for html <a name="get_min"></a>

=head2 static get_min : string

Returns '100001'.

=cut

sub get_min {
    return '100001';
}

=for html <a name="get_precision"></a>

=head2 static get_precision : int

Returns 18.

=cut

sub get_precision {
    return 18;
}

=for html <a name="get_width"></a>

=head2 static get_width : int

Returns 18.

=cut

sub get_width {
    return 18;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
