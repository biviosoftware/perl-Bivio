# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::AdmInstrumentSpinoffList;
use strict;
$Bivio::Biz::Model::AdmInstrumentSpinoffList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::AdmInstrumentSpinoffList::VERSION;

=head1 NAME

Bivio::Biz::Model::AdmInstrumentSpinoffList - list of spin-off info

=head1 SYNOPSIS

    use Bivio::Biz::Model::AdmInstrumentSpinoffList;

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::Biz::Model::AdmInstrumentSpinoffList::ISA = ('Bivio::Biz::ListModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::AdmInstrumentSpinoffList> list of spin-off info

=cut

#=IMPORTS
use Bivio::Biz::Model::Instrument;
use Bivio::Biz::Model::InstrumentSpinoff;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 static internal_initialize() : hash_ref

Declaration.

=cut

sub internal_initialize {
    return {
	version => 1,
	primary_key => [qw(
	    InstrumentSpinoff.spinoff_date
	    InstrumentSpinoff.source_instrument_id
	    InstrumentSpinoff.new_instrument_id
	)],
	order_by => [
	    'InstrumentSpinoff.spinoff_date',
	],
	other => [qw(
	    InstrumentSpinoff.remaining_basis
	    InstrumentSpinoff.new_shares_ratio
            ),
	    {
		name => 'source_name',
		type => 'Line',
		constrant => 'NOT_NULL',
	    },
	    {
		name => 'new_name',
		type => 'Line',
		constrant => 'NOT_NULL',
	    },
	],
    };
}

=for html <a name="internal_post_load_row"></a>

=head2 internal_post_load_row(hash_ref row)

Loads the name/ticker fields for the source and new instruments.

=cut

sub internal_post_load_row {
    my($self, $row) = @_;
    my($inst) = Bivio::Biz::Model::Instrument->new($self->get_request);

    foreach my $prefix (qw(source new)) {
	$inst->load({instrument_id => $row->{
	    'InstrumentSpinoff.'.$prefix.'_instrument_id'}});
	$row->{$prefix.'_name'} = $inst->format_name_ticker_symbol;
    }
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
