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

Compare C<PrimaryId> values using C<eq> and C<ne>, B<not> the numeric
equivalents.  PrimaryIds are larger that fit into a 32-bit integer.

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

Late breaking news.... The fifth digit is now a tag to allow us to
load static info, e.g. FileVolume index.

=cut


#=IMPORTS

#=VARIABLES
my($_FILE_VOLUME_TAG) = '1';

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

=for html <a name="from_literal"></a>

=head2 static from_literal(string value) : string

Make sure is at least one digit long, non-zero, and unsigned.

=cut

sub from_literal {
    my(undef, $value) = @_;
    return undef unless defined($value) && $value =~ /\S/;
    # Get rid of all blanks to be nice to user
    $value =~ s/\s+//g;
    $value =~ s/^0+//g;
    # Make sure is a digit.  Can't do more, because we allow
    # "special" primary ids (see Type::FileVolume).
    return $value if $value =~ /^\d+$/;
    return (undef, Bivio::TypeError::PRIMARY_ID());
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

Returns '100001'.  This is for automatically generated (sequence) primary
ids.   Special primary ids must always be below this value.

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

=for html <a name="set_file_volume_in_realm_id"></a>

=head2 set_file_volume_in_realm_id(string realm_id, int volume) : string

This guarantees a unique, static file volume id.

=cut

sub set_file_volume_in_realm_id {
    my($self, $realm_id, $volume) = @_;
    die($realm_id, ': invalid realm_id')
	    if $realm_id < get_min();
    substr($realm_id, -5, 3) = sprintf('%d%02d', $_FILE_VOLUME_TAG, $volume);
    return $realm_id;
}

=for html <a name="to_html"></a>

=head2 to_html(any value) : string

Converts value L<to_literal|"to_literal">.  If the value is undef, returns the
empty string.  Otherwise, returns as is--always valid html.

=cut

sub to_html {
    my($self, $value) = @_;
    return defined($value) ? $value : '';
}

=for html <a name="to_literal"></a>

=head2 to_literal(any value) : string

Converts value L<to_literal|"to_literal">.  If the value is undef, returns the
empty string.  Otherwise, returns as is--always valid literal.

=cut

sub to_literal {
    my($self, $value) = @_;
    return defined($value) ? $value : '';
}

=for html <a name="to_uri"></a>

=head2 to_uri(any value) : string

Converts value L<to_literal|"to_literal">.  If the value is undef, returns the
empty string.  Otherwise, returns as is--always valid uri.

=cut

sub to_uri {
    my($self, $value) = @_;
    return defined($value) ? $value : '';
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
