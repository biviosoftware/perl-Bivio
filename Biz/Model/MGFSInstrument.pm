# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::MGFSInstrument;
use strict;
$Bivio::Biz::Model::MGFSInstrument::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::MGFSInstrument - "base model" of MGFS company/index info

=head1 SYNOPSIS

    use Bivio::Biz::Model::MGFSInstrument;
    Bivio::Biz::Model::MGFSInstrument->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::Model::MGFSBase>

=cut

use Bivio::Biz::Model::MGFSBase;
@Bivio::Biz::Model::MGFSInstrument::ISA = ('Bivio::Biz::Model::MGFSBase');

=head1 DESCRIPTION

C<Bivio::Biz::Model::MGFSInstrument> is the "base model" of MGFS
company/index info

=cut

#=IMPORTS
use Bivio::Biz::Model::Instrument;
use Bivio::Type::InstrumentType;
use Bivio::Data::MGFS::Importer;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_INSTRUMENT);

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create(hash_ref new_values)

Creates an MGFS Instrument, and a corresponding Instrument model.

=cut

sub create {
    my($self, $new_values) = @_;

    return if $new_values->{mg_id} eq 'DATE';
    $_INSTRUMENT ||= Bivio::Biz::Model::Instrument->new($self->get_request);
    $_INSTRUMENT->create({
	name => $new_values->{name},
	ticker_symbol => $new_values->{symbol},
	instrument_type => Bivio::Type::InstrumentType::STOCK(),
	fed_tax_free => 0,
    });
    $new_values->{instrument_id} = $_INSTRUMENT->get('instrument_id');

    return $self->SUPER::create($new_values);
}

=for html <a name="internal_get_mgfs_import_format"></a>

=head2 internal_get_mgfs_import_format() : hash_ref

Returns the defintion of the models MGFS import format.

=cut

sub internal_get_mgfs_import_format {
    return {
	file => {
	    qspvsd => [0, 1],
	    qcpvsd => [0, 1],
	    indb01 => [1, 1],
	    chgdb01 => [1, 1],
	    changes => [2, 1],
	},
	format => [
	    {
		mg_id => ['ID', 4, 8],
		name => ['CHAR', 12, 80],
		symbol => ['CHAR', 92, 5],
	    },
	    {
		# skip sign on ID, always '+'
		mg_id => ['ID', 44, 8],
		name => ['CHAR', 129, 30],
		symbol => ['CHAR', 35, 8],
	    },
	],
    };
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'mgfs_instrument_t',
	columns => {
	    mg_id => ['Bivio::Data::MGFS::Id',
		    Bivio::SQL::Constraint::PRIMARY_KEY()],
            instrument_id => ['Bivio::Type::PrimaryId',
    		Bivio::SQL::Constraint::NOT_NULL()],
            name => ['Bivio::Type::Line',
    		Bivio::SQL::Constraint::NOT_NULL()],
            symbol => ['Bivio::Type::Name',
    		Bivio::SQL::Constraint::NOT_NULL()],
        },
    };
}

=for html <a name="update"></a>

=head2 update(hash_ref new_values)

Updates an MGFS Instrument, and its corresponding Instrument.

=cut

sub update {
    my($self, $new_values) = @_;
    return if $new_values->{mg_id} eq 'DATE';
    $self->SUPER::update($new_values);

    $new_values->{ticker_symbol} = $self->get('symbol');
    $_INSTRUMENT ||= Bivio::Biz::Model::Instrument->new($self->get_request);
    $_INSTRUMENT->unauth_load(instrument_id => $self->get('instrument_id'));
    $_INSTRUMENT->update($new_values);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
