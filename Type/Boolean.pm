# Copyright (c) 1999,2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Type::Boolean;
use strict;
$Bivio::Type::Boolean::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::Boolean::VERSION;

=head1 NAME

Bivio::Type::Boolean - formal numeric specification of the boolean type

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Type::Boolean;

=cut

=head1 EXTENDS

L<Bivio::Type::Integer>

=cut

use Bivio::Type::Integer;
@Bivio::Type::Boolean::ISA = qw(Bivio::Type::Integer);

=head1 DESCRIPTION

C<Bivio::Type::Boolean> describes the boolean type.  It is not a wrapper, just
something to convert.

=cut


=head1 CONSTANTS

=cut

=for html <a name="FALSE"></a>

=head2 FALSE : int

Returns 0

=cut

sub FALSE {
    return 0;
}

=for html <a name="TRUE"></a>

=head2 TRUE : int

Returns 1

=cut

sub TRUE {
    return 1;
}

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

Returns true.

=cut

sub can_be_zero {
    return 1;
}

=for html <a name="from_literal"></a>

=head2 static from_literal(string value) : array

Booleans are never non-null.  Always returns 0 or 1 or error.

=cut

sub from_literal {
    my($res, $err) = shift->SUPER::from_literal(@_);
    return defined($res) ? $res : $err ? ($res, $err) : 0;
}

=for html <a name="get_decimals"></a>

=head2 static get_decimals : int

Returns 0.

=cut

sub get_decimals {
    return 0;
}

=for html <a name="get_max"></a>

=head2 static get_max : int

Returns 1.

=cut

sub get_max {
    return 1;
}

=for html <a name="get_min"></a>

=head2 static get_min : int

Returns 0.

=cut

sub get_min {
    return 0;
}

=for html <a name="get_precision"></a>

=head2 static get_precision : int

Returns 1.

=cut

sub get_precision {
    return 1;
}

=for html <a name="get_width"></a>

=head2 static get_width : int

Returns 1.

=cut

sub get_width {
    return 1;
}

=for html <a name="to_sql_param"></a>

=head2 to_sql_param(string param) : string

Returns '0' or '1' for false (or undef) and true.

=cut

sub to_sql_param {
    shift;
    my($v) = shift;
    return !defined($v) ? undef : $v ? '1' : '0';
}

=for html <a name="to_xml"></a>

=head2 to_xml(string value) : string

Returns true or false.

=cut

sub to_xml {
    my($proto, $value) = @_;
    return !defined($value) ? '' : $value ? 'true' : 'false';
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
