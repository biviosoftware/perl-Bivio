# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::Type::DateInterval;
use strict;
$Bivio::Type::DateInterval::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::DateInterval::VERSION;

=head1 NAME

Bivio::Type::DateInterval - various date periods

=head1 SYNOPSIS

    use Bivio::Type::DateInterval;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Type::DateInterval::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Type::DateInterval> is a list and computations for various time
offsets:

=over 4

=item DAY : 1 day

=item WEEK : 7 days

=item MONTH : 30 days

=item QUARTER : 91 days

=item YEAR : 365 days

=back

=cut

#=IMPORTS
use Bivio::Type::DateTime;

#=VARIABLES
__PACKAGE__->compile([
    DAY => [
	1,
    ],
    WEEK => [
	7,
    ],
    MONTH => [
	30,
    ],
    QUARTER => [
	91,
    ],
    YEAR => [
	365,
    ],
    # negative values are interpreted, not actual
    BEGINNING_OF_YEAR => [
	-1,
    ],
]);

=head1 METHODS

=cut

=for html <a name="dec"></a>

=head2 dec(string date_time) : string

Returns I<date_time> decremented by this DateInterval.

=cut

sub dec {
    my($self, $date_time) = @_;
    return Bivio::Type::DateTime->add_days($date_time, -$self->as_int)
	    if $self->as_int >= 0;
    if ($self == $self->BEGINNING_OF_YEAR) {
	my($year) = (Bivio::Type::DateTime->to_parts($date_time))[5];
	return Bivio::Type::DateTime->date_from_parts(1, 1, $year);
    }
    die('unknown type: ', $self->get_name);
}

=for html <a name="inc"></a>

=head2 inc(string date_time) : string

Returns I<date_time> incremented by this DateInterval.

=cut

sub inc {
    my($self, $date_time) = @_;
    return Bivio::Type::DateTime->add_days($date_time, $self->as_int)
	    if $self->as_int >= 0;
    if ($self == $self->BEGINNING_OF_YEAR) {
	my($year) = (Bivio::Type::DateTime->to_parts($date_time))[5];
	return Bivio::Type::DateTime->date_from_parts(1, 1, $year + 1);
    }
    die('unknown type: ', $self->get_name);
}

=for html <a name="is_continuous"></a>

=head2 is_continuous() : boolean

Returns false.

=cut

sub is_continuous {
    return 0;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
