# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::PropertyModel::InstrumentValuation;
use strict;
$Bivio::Biz::PropertyModel::InstrumentValuation::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::PropertyModel::InstrumentValuation - a dated investment valuation

=head1 SYNOPSIS

    use Bivio::Biz::PropertyModel::InstrumentValuation;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::PropertyModel::InstrumentValuation::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::PropertyModel::InstrumentValuation> is the value of an
investment on a certain date.

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::Biz::FieldDescriptor;
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : array_ref

=cut

sub internal_initialize {
    my($property_info) = {
	'instrument_id' => ['Internal ID',
		Bivio::Biz::FieldDescriptor->lookup('NUMBER', 16)],
	'dttm' => ['Date',
		Bivio::Biz::FieldDescriptor->lookup('DATE')],
	'price_per_share' => ['Price Per Share',
		Bivio::Biz::FieldDescriptor->lookup('NUMBER', 19, 7)],
    };
    return [$property_info,
	    Bivio::SQL::Support->new('instrument_valuation_t',
		    keys(%$property_info)),
	    ['instrument_id', 'dttm']];
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
