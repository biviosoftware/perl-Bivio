# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::InstrumentSpinoffList;
use strict;
$Bivio::Biz::Model::InstrumentSpinoffList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::InstrumentSpinoffList::VERSION;

=head1 NAME

Bivio::Biz::Model::InstrumentSpinoffList - list of spin-off info

=head1 SYNOPSIS

    use Bivio::Biz::Model::InstrumentSpinoffList;

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::Biz::Model::InstrumentSpinoffList::ISA = ('Bivio::Biz::ListModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::InstrumentSpinoffList> list of spin-off info

=cut

#=IMPORTS
use Bivio::Biz::Model::Instrument;
use Bivio::Biz::Model::InstrumentSpinoff;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_SEPARATOR) = Bivio::Biz::Model::InstrumentSpinoff::QUERY_SEPARATOR;

=head1 METHODS

=cut

=for html <a name="format_query"></a>

=head2 format_query(Bivio::Type::QueryType type) : string

Returns the multiple key string for the current row.

=cut

sub format_query {
    my($self, $type, @args) = @_;

    $type = $type->get_name if ref($type);
    return $self->SUPER::format_query($type, @args)
	    unless $type eq 'THIS_DETAIL';

    return "t=".Bivio::Type::Date->to_query($self->get(
	    'InstrumentSpinoff.spinoff_date'))
	    .$_SEPARATOR
	    .$self->get('InstrumentSpinoff.source_instrument_id')
	    .$_SEPARATOR
	    .$self->get('InstrumentSpinoff.new_instrument_id');
}

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
