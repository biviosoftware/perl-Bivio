# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::MGFSInstrument;
use strict;
$Bivio::Biz::Model::MGFSInstrument::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::MGFSInstrument::VERSION;

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
use Bivio::Data::MGFS::DataType;
use Bivio::Type::InstrumentType;
use Bivio::Type::Line;
use Bivio::Type::Name;
use Bivio::Type::PrimaryId;
use Bivio::Data::MGFS::Id;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
#my($_INSTRUMENT);

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Agent::Request req) : Bivio::Biz::Model::MGFSInstrument

Creates a new MGFS Instrument model.

=cut

sub new {
    my($self) = &Bivio::Biz::Model::MGFSBase::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create(hash_ref new_values)

Creates an MGFS Instrument, and a corresponding Instrument model.

=cut

sub create {
    my($self, $new_values) = @_;
    return if $new_values->{mg_id} eq 'DATE';
    # workaround for unnamed MGFS data
    return if $new_values->{name} eq '';

    $new_values = _synchronize_instrument($self, $new_values, 0);
    return $self->SUPER::create($new_values);
}

=for html <a name="from_mgfs"></a>

=head2 from_mgfs(string record, string file) : boolean

Overrides from_mgfs to determine if it is a stock record.

=cut

sub from_mgfs {
    my($self, $record, $file) = @_;
    my($fields) = $self->{$_PACKAGE};

    if ($file =~ /^q/) {
	# all q files are stocks
	$fields->{is_stock} = 1;
    }
    else {
	my($data_type) = Bivio::Data::MGFS::DataType->from_mgfs(
		substr($record, 4, 1));
	if ($data_type == Bivio::Data::MGFS::DataType::STOCK()) {
	    $fields->{is_stock} = 1;
	    $fields->{ignore_name} = 1;
	}
	else {
	    $fields->{is_stock} = 0;
	}
    }
    return $self->SUPER::from_mgfs($record, $file);
}

=for html <a name="internal_get_mgfs_import_format"></a>

=head2 internal_get_mgfs_import_format() : hash_ref

Returns the defintion of the models MGFS import format.

=cut

sub internal_get_mgfs_import_format {
    return {
	file => {
	    indb01 => [0, Bivio::Biz::Model::MGFSBase::CREATE_ONLY()],
	    chgdb01 => [0, Bivio::Biz::Model::MGFSBase::CREATE_OR_UPDATE()],
	    qspvsd => [1, Bivio::Biz::Model::MGFSBase::UPDATE_ONLY()],
	    qcpvsd => [1, Bivio::Biz::Model::MGFSBase::UPDATE_ONLY()],
	},
	format => [
	    {
		# skip sign on ID, always '+'
		mg_id => ['ID', 44, 8],
		name => ['CHAR', 129, 30],
		symbol => ['CHAR', 35, 8],
	    },
            {
                mg_id => ['ID', 4, 8],
                name => ['CHAR', 12, 80],
                symbol => ['CHAR', 92, 5],
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
	    mg_id => ['Bivio::Data::MGFS::Id', 'PRIMARY_KEY'],
            instrument_id => ['PrimaryId', 'NOT_NULL'],
            name => ['Line', 'NOT_NULL'],
            symbol => ['Name', 'NOT_NULL'],
        },
    };
}

=for html <a name="update"></a>

=head2 update(hash_ref new_values)

Updates an MGFS Instrument, and its corresponding Instrument.

=cut

sub update {
    my($self, $new_values) = @_;
    my($fields) = $self->{$_PACKAGE};
    return if defined($new_values->{mg_id})
	    && ($new_values->{mg_id} eq 'DATE');
    # workaround for unnamed MGFS data
    return if exists($new_values->{name}) && $new_values->{name} eq '';

    # ignore the name when updating from CHGDB01
    # the names are much better in the Q files
    if ($fields->{ignore_name}) {
	$new_values->{name} = $self->get('name');
    }

    $new_values = _synchronize_instrument($self, $new_values, 1);
    $self->SUPER::update($new_values);
    return;
}

#=PRIVATE METHODS

# _abbreviate_name(hash_ref values)
#
# Abbreviates the instrument name if present.
#
sub _abbreviate_name {
    my($values) = @_;
    return unless exists($values->{name});
    $values->{name} = Bivio::Biz::Model::Instrument->abbreviate_name(
	    $values->{name});
    return;
}

# _synchronize_instrument(hash_ref new_values, boolean update) : hash_ref
#
# Updates or creates a corresponding Instrument from the values.
#
sub _synchronize_instrument {
    my($self, $new_values, $update) = @_;
    my($fields) = $self->{$_PACKAGE};

    _abbreviate_name($new_values);

    # only create/update if it is a stock
    if ($fields->{is_stock} || ($update && $self->get('instrument_id'))) {
#	$_INSTRUMENT ||= Bivio::Biz::Model::Instrument->new(
#		$self->get_request);
#
#	if ($update) {
#	    $new_values->{ticker_symbol} =
#		    exists($new_values->{symbol})
#			    ? $new_values->{symbol}
#			    : $self->get('symbol');
#	    $_INSTRUMENT->unauth_load(instrument_id =>
#		    $self->get('instrument_id'));
#	    $_INSTRUMENT->update($new_values);
#	}
#	else {
#	    $_INSTRUMENT->create({
#		name => $new_values->{name},
#		ticker_symbol => $new_values->{symbol},
#		instrument_type => Bivio::Type::InstrumentType::STOCK(),
#		fed_tax_free => 0,
#	    });
#	    $new_values->{instrument_id} = $_INSTRUMENT->get('instrument_id');
#	}
    }
    # otherwise, make the symbol the same as the mg_id for uniqueness
    # it is an industry or composite record
    else {
	$new_values->{symbol} = $new_values->{mg_id};
    }
    return $new_values;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
