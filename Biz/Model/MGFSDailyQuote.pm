# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::MGFSDailyQuote;
use strict;
$Bivio::Biz::Model::MGFSDailyQuote::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::MGFSDailyQuote - provide daily quotes formats

=head1 SYNOPSIS

    use Bivio::Biz::Model::MGFSDailyQuote;
    Bivio::Biz::Model::MGFSDailyQuote->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::Model::MGFSBase>

=cut

use Bivio::Biz::Model::MGFSBase;
@Bivio::Biz::Model::MGFSDailyQuote::ISA = ('Bivio::Biz::Model::MGFSBase');

=head1 DESCRIPTION

C<Bivio::Biz::Model::MGFSDailyQuote>

=cut

#=IMPORTS
use Bivio::Data::MGFS::Amount;
use Bivio::Data::MGFS::Date;
use Bivio::Data::MGFS::Id;
use Bivio::Data::MGFS::Quote;

=head1 CONSTANTS

=cut

=for html <a name="FRACTIONAL_ALIGNMENT"></a>

=head2 FRACTIONAL_ALIGNMENT : float

returns 1 / 64

=cut

sub FRACTIONAL_ALIGNMENT {
    return 1 / 64;
}

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_DATES) = 'a8' x 265;
my($_AMOUNTS) = 'a6' x 265;

# used to unsplit values, it is keyed by mg_id and contains an
# array of date, factor pairs
my($_SPLITS) = {};

=begin comment

NO POINT! MGFS seems to use 3 decimal factor, not actual value
see CCK '89

# from the MGFS Glossary, Stock Split and Stock Dividend Factors
# increase the precision on rounded values
my($_FACTORS) = {
    # Dividends
    '.99' => 1 / 1.01,
    '.98' => 1 / 1.02,
    '.971' => 1 / 1.03,
    '.962' => 1/ 1.04,
    '.952' => 1 / 1.05,
    '.943' => 1 / 1.06,
    '.935' => 1 / 1.07,
    '.926' => 1 / 1.08,
    '.917' => 1 / 1.09,
    '.909' => 1 / 1.1,
    '.901' => 1 / 1.11,
    '.893' => 1 / 1.12,
    '.885' => 1 / 1.13,
    '.877' => 1 / 1.14,
    '.87' => 1 / 1.15,
    '.862' => 1 / 1.16,
    '.855' => 1 / 1.17,
    '.847' => 1 / 1.18,
    '.84' => 1 / 1.19,
    '.833' => 1 / 1.2,
    '.8' => 1 / 1.25,
    '.769' => 1 / 1.3,
    '.752' => 1 / 1.33,
    '.75' => 1 / 1.333,
    '.714' => 1 / 1.4,
    '.667' => 1 / 1.5,
    '.625' => 1 / 1.6,
    '.571' => 1 / 1.75,
    '.556' => 1 / 1.8,
    '.5' => 1 / 2,
    '.333' => 1 / 3,
    '.976' => 1 / 1.025,
    '.966' => 1 / 1.035,
    '.957' => 1 / 1.045,
    '.948' => 1 / 1.055,
    '.939' => 1 / 1.065,
    '.93' => 1 / 1.075,
    '.922' => 1 / 1.085,
    '.913' => 1 / 1.095,
    '.905' => 1 / 1.105,
    # Splits
    '.333' => 1 / 3,
    '.167' => 1 / 6,
    '.143' => 1 / 7,
    '.111' => 1 / 9,
    '.667' => 2 / 3,
    '.833' => 5 / 6,
    '.286' => 2 / 7,
    '.429' => 3 / 7,
    '.571' => 4 / 7,
    '.714' => 5 / 7,
    '.857' => 6 / 7,
    '1.333' => 4 / 3,
    '33.333' => 100 / 3,
};

=cut

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Agent::Request req) : Bivio::Biz::Model::MGFSDailyQuote

Creates a new MGFS Daily Quote model.

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

Creates an MGFS Daily Quote. Does price unsplitting.
Does nothing for all 0 values.

=cut

sub create {
    my($self, $new_values) = @_;
    return if $new_values->{close} == 0
	    && $new_values->{low} == 0
		    && $new_values->{high} == 0
			    && $new_values->{volume} == 0;
    $self->SUPER::create(_unsplit($new_values));
    return;
}

=for html <a name="from_mgfs"></a>

=head2 from_mgfs(string record, string file)

Overrides MGFSBase.from_mgfs to deal with the one-to-many format for
MGFS quotes.

=cut

sub from_mgfs {
    my($self, $record, $file) = @_;
    my($fields) = $self->{$_PACKAGE};

    # process the indb02 and chgdb02 files normally
    if ($file eq 'indb02' || $file eq 'chgdb02') {
	$self->SUPER::from_mgfs($record, $file);
	return;
    }

    # workaround for unnamed MGFS data, ignore quotes for unnamed instruments
    my($name) = substr($record, 12, 80);
    # trim spaces
    $name =~ s/\s+$//;
    return if $name eq '';

    # date records store the array in a local var
    my($record_id) = substr($record, 4, 8);
    if ($record_id =~/^DATE/) {
	my(@dates) = unpack($_DATES, substr($record, 48, 2120));
	foreach my $date (@dates) {
	    if ($date =~ /^00000000$/) {
		$date = undef;
	    }
	    else {
		$date = Bivio::Data::MGFS::Date->from_mgfs($date);
	    }
	}
	$fields->{dates} = \@dates;
    }
    # quote records iterate all the dates and create models
    else {
	$fields->{mg_id} = Bivio::Data::MGFS::Id->from_mgfs($record_id);
	my($format_switch) = substr($record, 106, 1);
	my(@highs) = unpack($_AMOUNTS, substr($record, 107, 1590));
	my(@lows) = unpack($_AMOUNTS, substr($record, 1697, 1590));
	my(@closes) = unpack($_AMOUNTS, substr($record, 3287, 1590));
	# add decimal point, except for format 'x'
	if ($format_switch ne 'x') {
	    _add_decimal(\@highs);
	    _add_decimal(\@lows);
	    _add_decimal(\@closes);
	}
	my(@volumes) = unpack($_AMOUNTS, substr($record, 4877, 1590));
	# volume in hundreds
	foreach my $volume (@volumes) {
	    $volume .= '00';
	}
	my($dates) = $fields->{dates};
	my($id) = $fields->{mg_id};

	my($values) = {mg_id => $id};
	for (my($i) = 0; $i < 265; $i++) {
	    last unless defined($dates->[$i]);
	    $values->{date_time} = $dates->[$i];
	    $values->{high} = $highs[$i];
	    $values->{low} = $lows[$i];
	    $values->{close} = $closes[$i];
	    $values->{volume} = $volumes[$i];

	    # update_flag of 2, meaning don't replace, create only if not there
	    my($die) = $self->try_to_update_or_create($values, 2);
	    if ($die) {
		$self->write_reject_record($die, $record);
		last;
	    }
	}
    }
    return;
}

=for html <a name="internal_get_mgfs_import_format"></a>

=head2 internal_get_mgfs_import_format() : hash_ref

Returns the defintion of the models MGFS import format.

=cut

sub internal_get_mgfs_import_format {
    return {
	file => {
	    # new update_flag 2, won't change existing records
	    qspvsd => [0, 2],
	    qcpvsd => [0, 2],
	    indb02 => [1, 1],
	    chgdb02 => [1, 1],
	},
	format => [
	    {
		# handled internally by this class
	    },
	    {
		# skips sign from id, always +
		mg_id => ['ID', 44, 8],
		date_time => ['CHAR', 82, 9],
		close => ['DOLLARS', 91, 8],
		high => ['DOLLARS', 99, 8],
		low => ['DOLLARS', 107, 8],
		volume => ['HUNDREDS', 1287, 10],
	    }
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
	table_name => 'mgfs_daily_quote_t',
	columns => {
	    mg_id => ['Bivio::Data::MGFS::Id',
		Bivio::SQL::Constraint::PRIMARY_KEY()],
            date_time => ['Bivio::Data::MGFS::Date',
		Bivio::SQL::Constraint::PRIMARY_KEY()],
	    high => ['Bivio::Data::MGFS::Quote',
    		Bivio::SQL::Constraint::NOT_NULL()],
            low => ['Bivio::Data::MGFS::Quote',
    		Bivio::SQL::Constraint::NOT_NULL()],
            close => ['Bivio::Data::MGFS::Quote',
    		Bivio::SQL::Constraint::NOT_NULL()],
            volume => ['Bivio::Data::MGFS::Amount',
    		Bivio::SQL::Constraint::NOT_NULL()],
        },
    };
}

=for html <a name="update"></a>

=head2 update(hash_ref new_values)

Updates an MGFS Daily Quote. Does price unsplitting.

=cut

sub update {
    my($self, $new_values) = @_;
    $self->SUPER::update(_unsplit($new_values));
    return;
}

#=PRIVATE METHODS

# _add_decimal(array_ref values)
#
# Iterates each value and inserts a '.' before the second-to-last digit.
#
sub _add_decimal {
    my($values) = @_;
    foreach my $value (@$values) {
	$value =~ s/^(.*)(..)$/$1\.$2/;
    }
}

# _align(string value) : string
#
# Aligns the value along the FRACTIONAL_ALIGNMENT boundary.
#
sub _align {
    my($value) = @_;
    my($whole) = int($value);
    my($div) = int(($value - $whole) / FRACTIONAL_ALIGNMENT() + 0.5);
    return $whole + $div * FRACTIONAL_ALIGNMENT();
}

# _get_splits(string mg_id) : array_ref
#
# Loads the global var _SPLITS with an array of date, factor pairs for the
# specified mg_id. Returns the array.
#
sub _get_splits {
    my($mg_id) = @_;

    my($d) = Bivio::Type::Date->from_sql_value('date_time');
    my($sth) = Bivio::SQL::Connection->execute(
            <<"EOF", [$mg_id]);
            SELECT $d, factor
            FROM mgfs_split_t
            WHERE mg_id=?
            ORDER BY date_time
EOF

    my($result) = [];
    my($row, $date, $factor);
    while ($row = $sth->fetchrow_arrayref()) {
	($date, $factor) = @$row;
#	$factor = $_FACTORS->{$factor} || $factor;
	$date = Bivio::Type::Date->from_sql_column($date);
	# only interested in first part
	$date =~ s/^(.*)\s/$1/;
	push(@$result, $date);
	push(@$result, $factor);
    }
    $_SPLITS->{$mg_id} = $result;
    return $result;
}

# _unsplit(hash_ref values) : hash_ref
#
# Unsplits 'high', 'low', and 'close' by the split factors up to that 'date'.
# Returns the same hash_ref.
#
sub _unsplit {
    my($values) = @_;
    my($mg_id) = $values->{mg_id};
    my($date) = $values->{date_time};
    # only interested in first part
    $date =~ s/^(.*)\s/$1/;

    my($aligned) = 0;
    my($splits) = $_SPLITS->{$mg_id} || _get_splits($mg_id);
    for (my($i) = int(@$splits) - 2; $i >= 0; $i -= 2) {
	if ($date < $splits->[$i]) {
	    my($factor) = $splits->[$i+1];
	    $values->{close} /= $factor;
	    $values->{high} /= $factor;
	    $values->{low} /= $factor;

	    # align along fractional boundary
	    $values->{close} = _align($values->{close});
	    $values->{high} = _align($values->{high});
	    $values->{low} = _align($values->{low});
	    $aligned = 1;
	}
	else {
	    # splits are ordered by date, so can skip the rest
	    last;
	}
    }
    unless ($aligned) {
	# align along fractional boundary
	$values->{close} = _align($values->{close});
	$values->{high} = _align($values->{high});
	$values->{low} = _align($values->{low});
    }

    return $values;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
