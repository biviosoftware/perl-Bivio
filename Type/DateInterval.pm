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

=item NONE : 0 days

=item DAY : 1 day

=item WEEK : 7 days

=item MONTH

A month relative to current date/time.  Time component unmodified.

=item YEAR

A year relative to current date/time.  Time component unmodified.

=item BEGINNING_OF_YEAR

The beginning of next year if L<inc|"inc">.
The beginning of this year if L<dec|"dec">.
Time component unmodified.

=back

=cut

#=IMPORTS
use Bivio::Type::DateTime;

#=VARIABLES
__PACKAGE__->compile([
    NONE => [
        0,
    ],
    DAY => [
	1,
    ],
    WEEK => [
	7,
    ],
    # negative values are interpreted, not actual
    BEGINNING_OF_YEAR => [
	-1,
    ],
    MONTH => [
	-2,
    ],
    YEAR => [
	-3,
    ],
    FISCAL_YEAR => [
	-4,
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
    return &{\&{'_dec_'.lc($self->get_name)}}($date_time);
}

=for html <a name="inc"></a>

=head2 inc(string date_time) : string

Returns I<date_time> incremented by this DateInterval.

=cut

sub inc {
    my($self, $date_time) = @_;
    return Bivio::Type::DateTime->add_days($date_time, $self->as_int)
	    if $self->as_int >= 0;
    return &{\&{'_inc_'.lc($self->get_name)}}($date_time);
}

=for html <a name="is_continuous"></a>

=head2 is_continuous() : boolean

Returns false.

=cut

sub is_continuous {
    return 0;
}

#=PRIVATE METHODS

# _dec_beginning_of_year(string date_time) : string
#
# Goes to beginning of this year.
#
sub _dec_beginning_of_year {
    my($date_time) = @_;
    my($sec, $min, $hour, $mday, $mon, $year)
	    = Bivio::Type::DateTime->to_parts($date_time);
    return Bivio::Type::DateTime->from_parts_or_die($sec, $min, $hour,
	    1, 1, $year);
}

# _dec_month(string date_time) : string
#
# Goes to same date/time in previous month.  Goes to end of month if outside
# of month boundary.
#
sub _dec_month {
    my($date_time) = @_;
    my($sec, $min, $hour, $mday, $mon, $year)
	    = Bivio::Type::DateTime->to_parts($date_time);
    $mon = $mon == 1 ? ($year--, 12) : $mon - 1;
    return _from_parts_with_mday_correction($sec, $min, $hour,
	    $mday, $mon, $year);
}

# _dec_year(string date_time) : string
#
# Goes to same date/time in previous year.  Goes to month of year if outside
# of month boundary.
#
sub _dec_year {
    my($date_time) = @_;
    my($sec, $min, $hour, $mday, $mon, $year)
	    = Bivio::Type::DateTime->to_parts($date_time);
    return _from_parts_with_mday_correction($sec, $min, $hour,
	    $mday, $mon, $year - 1);
}

# _from_parts_with_mday_correction(int sec, int min, int hour, int mday, int mon, int year) : string
#
# Returns DateTime->from_parts correcting mday to be at month's end
# if not already at month's end.
#
sub _from_parts_with_mday_correction {
    my($sec, $min, $hour, $mday, $mon, $year) = @_;
    my($last) = Bivio::Type::DateTime->get_last_day_in_month($mon, $year);
    return Bivio::Type::DateTime->from_parts_or_die($sec, $min, $hour,
	    $mday > $last ? $last : $mday, $mon, $year);
}

# _inc_beginning_of_year(string date_time) : string
#
# Goes to beginning of next year.
#
sub _inc_beginning_of_year {
    my($date_time) = @_;
    my($sec, $min, $hour, $mday, $mon, $year)
	    = Bivio::Type::DateTime->to_parts($date_time);
    return Bivio::Type::DateTime->from_parts_or_die($sec, $min, $hour,
	    $mday, $mon, 1 + $year);
}

# _inc_fiscal_year(string date_time) : string
#
# Same as calling _inc_beginning_of_year, but has fiscal year name.
#
sub _inc_fiscal_year {
    my($date_time) = @_;
    return _inc_beginning_of_year($date_time);
}

# _inc_month(string date_time) : string
#
# Goes to same date/time next month.  Goes to end of month if outside
# of month boundary.
#
sub _inc_month {
    my($date_time) = @_;
    my($sec, $min, $hour, $mday, $mon, $year)
	    = Bivio::Type::DateTime->to_parts($date_time);
    $mon = $mon == 12 ? ($year++, 1) : $mon + 1;
    return _from_parts_with_mday_correction($sec, $min, $hour,
	    $mday, $mon, $year);
}

# _inc_year(string date_time) : string
#
# Goes to same date/time in previous year.  Goes to month of year if outside
# of month boundary.
#
sub _inc_year {
    my($date_time) = @_;
    my($sec, $min, $hour, $mday, $mon, $year)
	    = Bivio::Type::DateTime->to_parts($date_time);
    return _from_parts_with_mday_correction($sec, $min, $hour,
	    $mday, $mon, $year + 1);
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
