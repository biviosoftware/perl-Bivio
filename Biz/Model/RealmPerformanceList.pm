# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::RealmPerformanceList;
use strict;
$Bivio::Biz::Model::RealmPerformanceList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::RealmPerformanceList - realm performance monthly events

=head1 SYNOPSIS

    use Bivio::Biz::Model::RealmPerformanceList;
    Bivio::Biz::Model::RealmPerformanceList->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::Model::MonthlyPerformanceList>

=cut

use Bivio::Biz::Model::MonthlyPerformanceList;
@Bivio::Biz::Model::RealmPerformanceList::ISA = ('Bivio::Biz::Model::MonthlyPerformanceList');

=head1 DESCRIPTION

C<Bivio::Biz::Model::RealmPerformanceList> realm performance monthly events

=cut

#=IMPORTS
use Bivio::Biz::Accounting::UnitCalculator;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Biz::Model::RealmPerformanceList

Creates a new performance list

=cut

sub new {
    # using dynamic lookup, no new in immediate super class
    my($self) = shift->SUPER::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="internal_get_count"></a>

=head2 internal_get_count(hash_ref row) : string

Returns the number of units/shares purchased for the specified data
row.

=cut

sub internal_get_count {
    my($self, $row) = @_;
    return $row->{'MemberEntry.units'};
}

=for html <a name="internal_get_end_value"></a>

=head2 internal_get_end_value(string date) : (string, string)

Returns the (value, count) for the specified ending date.

=cut

sub internal_get_end_value {
    my($self, $date) = @_;
    return _get_value($self, $date);
}

=for html <a name="internal_get_start_value"></a>

=head2 internal_get_start_value(string start_date, string end_date) : (string, string)

Returns the (value, count) for the specified starting date.

=cut

sub internal_get_start_value {
    my($self, $start_date, $end_date) = @_;
    return _get_value($self, $start_date);
}

#=PRIVATE METHODS

# _get_value(string date) : (string, string)
#
# Returns the (value, units) for the specified date.
#
sub _get_value {
    my($self, $date) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{unit_calculator} ||=
	    Bivio::Biz::Accounting::UnitCalculator->new($self->get_request);
    my($uc) = $fields->{unit_calculator};

    return ($uc->get_value($date), $uc->get_units($date));
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
