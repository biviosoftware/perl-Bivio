# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::InstrumentSpinoff;
use strict;
$Bivio::Biz::Model::InstrumentSpinoff::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::InstrumentSpinoff::VERSION;

=head1 NAME

Bivio::Biz::Model::InstrumentSpinoff - spin-off info

=head1 SYNOPSIS

    use Bivio::Biz::Model::InstrumentSpinoff;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::InstrumentSpinoff::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::InstrumentSpinoff> spin-off info

=cut

=head1 CONSTANTS

=cut

=for html <a name="QUERY_SEPARATOR"></a>

=head2 QUERY_SEPARATOR : string

Returns the separator used between the multiple key query.

=cut

sub QUERY_SEPARATOR {
    return '-';
}

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_SEP) = QUERY_SEPARATOR();

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'instrument_spinoff_t',
	columns => {
	    spinoff_date => ['Date', 'PRIMARY_KEY'],
	    source_instrument_id => ['PrimaryId', 'PRIMARY_KEY'],
	    new_instrument_id => ['PrimaryId', 'PRIMARY_KEY'],
	    remaining_basis => ['Amount', 'NOT_NULL'],
	    new_shares_ratio => ['Amount', 'NOT_NULL'],
        },
    };
}

=for html <a name="load_this_from_request"></a>

=head2 load_this_from_request() : self

Overridden to handle the multiple keys.

=cut

sub load_this_from_request {
    my($self) = @_;
    my($date, $source, $new);

    my($this) = $self->get_request->get('query')->{t};
    if ($this) {
	($date, $source, $new) = $this =~ /^(.*)$_SEP(\d+)$_SEP(\d+)$/;
    }
    $self->throw_die(Bivio::DieCode::CORRUPT_QUERY())
	    unless $date;

    return $self->load({
	spinoff_date => Bivio::Type::Date->from_literal($date),
	source_instrument_id => $source,
	new_instrument_id => $new,
    });
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
