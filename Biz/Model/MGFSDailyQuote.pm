# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::MGFSDailyQuote;
use strict;
$Bivio::Biz::Model::MGFSDailyQuote::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::MGFSDailyQuote::VERSION;

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

# quotes which use the new decimal format, mg_id => ticker
# the ticker isn't used now, but could be used for validation
my($_DECIMAL_QUOTES) = {
    # 8/28/2000
    '00020707' => 'APC', # Anadarko Petroleum
    '00009423' => 'FDX', # Fedex
    '00032024' => 'GTW', # Gateway
    '00004604' => 'HUG', # Hughes Supply
    '00014900' => 'MNS', # MSC Software
    '00002569' => 'FCEA', # Forest City class A
    '00016051' => 'FCEB', # Forest City class B

    '00002883' => 'MEGA',
    '00007429' => 'RBC',
    '00021559' => 'PMD',
    '00040587' => 'GBT',
    '00041507' => 'ONT',
    '00043074' => 'EMA',

    # 9/25/2000 NYSE
    '00000392' => 'CL',
    '00000787' => 'GT',
    '00001665' => 'S',
    '00002594' => 'H',
    '00003419' => 'VAL',
    '00005597' => 'TRC',
    '00005964' => 'MTB',
    '00006066' => 'STT',
    '00006752' => 'TAI',
    '00008132' => 'TM',
    '00013741' => 'CI',
    '00014597' => 'NHL',
    '00015319' => 'IOM',
    '00015873' => 'BEN',
    '00016413' => 'CPQ',
    '00016831' => 'TWX',
    '00017276' => 'WSO',
    '00017537' => 'KF',
    '00018459' => 'LSS',
    '00019117' => 'GMH',
    '00019158' => 'CBU',
    '00020887' => 'LE',
    '00021053' => 'HAR',
    '00023656' => 'NSS',
    '00023752' => 'DON',
    '00023796' => 'HYP',
    '00024980' => 'KSM',
    '00025155' => 'CXH',
    '00025784' => 'VIG',
    '00028311' => 'DTF',
    '00028816' => 'AOL',
    '00030636' => 'RCL',
    '00031063' => 'SGY',
    '00032491' => 'MLM',
    '00033360' => 'SH',
    '00033988' => 'ADO',
    '00034224' => 'LMT',
    '00035902' => 'MHI',
    '00036596' => 'FDS',
    '00037718' => 'ASF',
    '00038300' => 'ACR',
    '00039197' => 'DA',
    '00039226' => 'AXM',
    '00040633' => 'DCX',
    '00040707' => 'MMR',
    '00041055' => 'PTZ',
    '00041538' => 'HBC',
    '00041988' => 'EN',
    '00048177' => 'UBS',

    # 9/25/2000 AMEX
    '00000713' => 'MMG',
    '00002133' => 'AND',
    '00002134' => 'NBR',
    '00002730' => 'IMO',
    '00003370' => 'TAM',
    '00007525' => 'BIOB',
    '00007983' => 'CGN',
    '00010363' => 'KEA',
    '00010791' => 'BIOA',
    '00011095' => 'FEI',
    '00013532' => 'TDS',
    '00015092' => 'HDR',
    '00016414' => 'CVM',
    '00017465' => 'HH',
    '00017547' => 'TTE',
    '00018509' => 'AMK',
    '00018784' => 'IVX',
    '00018934' => 'IDX',
    '00019773' => 'FAX',
    '00021289' => 'ORG',
    '00023463' => 'LDR',
    '00023857' => 'USM',
    '00024419' => 'DVN',
    '00027421' => 'PSB',
    '00031696' => 'NVR',
    '00031958' => 'TXB',
    '00033928' => 'SWC',
    '00034199' => 'SOS',
    '00034812' => 'TWA',
    '00035384' => 'IMH',
    '00035432' => 'NOX',
    '00035653' => 'TTP',
    '00035773' => 'EE',
    '00036696' => 'FSW',
    '00037404' => 'TWW',
    '00038903' => 'CHC',
    '00039383' => 'RAS',
    '00039808' => 'EEE',
    '00040274' => 'SVI',

    # 12/4/2000 NYSE
    '00000078' => 'AHP',
    '00000147' => 'ASH',
    '00028439' => 'ASP',
    '00029808' => 'AWG',
    '00003734' => 'ATW',
    '00018059' => 'ABX',
    '00002204' => 'BBC',
    '00013507' => 'BLC',
    '00022027' => 'BLU',
    '00003767' => 'BN',
    '00032712' => 'BVF',
    '00027927' => 'BXM',
    '00038435' => 'BYH',
    '00032214' => 'CGI',
    '00022559' => 'CLM',
    '00025798' => 'QCMM',
    '00048261' => 'CYH',
    '00004204' => 'DLX',
    '00033121' => 'DOM',
    '00039198' => 'DRF',
    '00030170' => 'DUC',
    '00026483' => 'EF',
    '00035512' => 'ESA',
    '00001466' => 'EXC',
    '00036306' => 'EXE',
    '00022066' => 'FUN',
    '00020659' => 'FVH',
    '00032818' => 'GDI',
    '00004481' => 'GLT',
    '00033441' => 'GRO',
    '00023643' => 'GVT',
    '00007269' => 'HAT',
    '00026563' => 'HCA',
    '00049183' => 'HED',
    '00031557' => 'IT',
    '00041554' => 'ITB',
    '00001051' => 'KMB',
    '00028441' => 'LHP',
    '00014941' => 'LSI',
    '00005508' => 'LUV',
    '00030815' => 'MAD',
    '00001177' => 'MAT',
    '00033760' => 'MCK',
    '00010831' => 'MDC',
    '00006021' => 'MI',
    '00029418' => 'MIC',
    '00004917' => 'MPR',
    '00029403' => 'MQY',
    '00010438' => 'MTR',
    '00037248' => 'MWY',
    '00030909' => 'MYS',
    '00000951' => 'N',
    '00001277' => 'NSH',
    '00023704' => 'OMS',
    '00001504' => 'POM',
    '00033785' => 'PVD',
    '00018661' => 'RBK',
    '00035845' => 'REV',
    '00027343' => 'SE',
    '00007964' => 'SFD',
    '00018266' => 'SIE',
    '00048690' => 'SJM',
    '00025716' => 'SLR',
    '00038353' => 'SVR',
    '00035292' => 'SWM',
    '00010118' => 'SYK',
    '00003327' => 'TBC',
    '00039935' => 'TDR',
    '00005624' => 'TMO',
    '00027344' => 'TVX',
    '00001943' => 'VFC',
    '00028664' => 'VGM',
    '00025058' => 'VLT',
    '00027765' => 'VTS',
    '00038443' => 'WLK',
    '00031289' => 'WLV',
    '00039483' => 'WPC',
    '00025236' => 'WS',
    '00031180' => 'WXS',
    '00024382' => 'ZTR',
};

# used to unsplit values, it is keyed by mg_id and contains an
# array of date, factor pairs
my($_SPLITS) = {};

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

=for html <a name="align_price"></a>

=head2 static align_price(string value) : string

Aligns I<value> along the L<FRACTIONAL_ALIGNMENT|"FRACTIONAL_ALIGNMENT">
boundary.

=cut

sub align_price {
    my($proto, $value) = @_;
    my($whole) = int($value);
    my($div) = int(($value - $whole) / $proto->FRACTIONAL_ALIGNMENT() + 0.5);
    return $whole + $div * $proto->FRACTIONAL_ALIGNMENT();
}

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
    $self->SUPER::create(_unsplit($self, $new_values));
    return;
}

=for html <a name="from_mgfs"></a>

=head2 from_mgfs(string record, string file) : boolean

Overrides MGFSBase.from_mgfs to deal with the one-to-many format for
MGFS quotes.

=cut

sub from_mgfs {
    my($self, $record, $file) = @_;
    my($fields) = $self->{$_PACKAGE};

    # process the indb02 and chgdb02 files normally
    if ($file eq 'indb02' || $file eq 'chgdb02') {
	return $self->SUPER::from_mgfs($record, $file);
    }

    # workaround for unnamed MGFS data, ignore quotes for unnamed instruments
    my($name) = substr($record, 12, 80);
    # trim spaces
    $name =~ s/\s+$//;
    return 1 if $name eq '';

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

	    # don't replace, create only if not there
	    my($die) = $self->try_to_update_or_create($values,
		   Bivio::Biz::Model::MGFSBase::CREATE_ONLY());
	    if ($die) {
		$self->write_reject_record($die, $record);
		return 0;
	    }
	}
    }
    return 1;
}

=for html <a name="internal_get_mgfs_import_format"></a>

=head2 internal_get_mgfs_import_format() : hash_ref

Returns the defintion of the models MGFS import format.

=cut

sub internal_get_mgfs_import_format {
    return {
	file => {
# no longer used, QSPVSD files only update once a month
#	    qspvsd => [0, Bivio::Biz::Model::MGFSBase::CREATE_ONLY()],
#	    qcpvsd => [0, Bivio::Biz::Model::MGFSBase::CREATE_ONLY()],
	    indb02 => [1, Bivio::Biz::Model::MGFSBase::CREATE_ONLY()],
	    chgdb02 => [1, Bivio::Biz::Model::MGFSBase::CREATE_ONLY()],
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
	    mg_id => ['Bivio::Data::MGFS::Id', 'PRIMARY_KEY'],
            date_time => ['Bivio::Data::MGFS::Date', 'PRIMARY_KEY'],
	    high => ['Bivio::Data::MGFS::Quote', 'NOT_NULL'],
            low => ['Bivio::Data::MGFS::Quote', 'NOT_NULL'],
            close => ['Bivio::Data::MGFS::Quote', 'NOT_NULL'],
            volume => ['Bivio::Data::MGFS::Amount', 'NOT_NULL'],
        },
    };
}

=for html <a name="update"></a>

=head2 update(hash_ref new_values)

Updates an MGFS Daily Quote. Does price unsplitting.

=cut

sub update {
    my($self, $new_values) = @_;
    $self->SUPER::update(_unsplit($self, $new_values));
    return;
}

=for html <a name="update_raw"></a>

=head2 update_raw(hash_ref new_values)

Updates an MGFS Daily Quote. Doesn't modify values like
L<update|"update">.

=cut

sub update_raw {
    my($self, $new_values) = @_;
    $self->SUPER::update($new_values);
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

# _unsplit(self, hash_ref values) : hash_ref
#
# Unsplits 'high', 'low', and 'close' by the split factors up to that 'date'.
# Returns the same hash_ref.
#
sub _unsplit {
    my($self, $values) = @_;
    my($mg_id) = $values->{mg_id};
    my($date) = $values->{date_time};
    return $values unless $date;
    # only interested in first part
    $date =~ s/^(.*)\s/$1/;

    # splits are aligned on a fractional boundary
    my($aligned) = 0;
    my($splits) = $_SPLITS->{$mg_id} || _get_splits($mg_id);
    for (my($i) = int(@$splits) - 2; $i >= 0; $i -= 2) {
	if ($date < $splits->[$i]) {
	    my($factor) = $splits->[$i+1];
	    $values->{close} /= $factor;
	    $values->{high} /= $factor;
	    $values->{low} /= $factor;

	    # align along fractional boundary
	    $values->{close} = $self->align_price($values->{close});
	    $values->{high} = $self->align_price($values->{high});
	    $values->{low} = $self->align_price($values->{low});
	    $aligned = 1;
	}
	else {
	    # splits are ordered by date, so can skip the rest
	    last;
	}
    }
#    if ($aligned || $_DECIMAL_QUOTES->{$mg_id}) {
#	;
#    }
#    else {
#	# align along fractional boundary
#	$values->{close} = $self->align_price($values->{close});
#	$values->{high} = $self->align_price($values->{high});
#	$values->{low} = $self->align_price($values->{low});
#    }

    return $values;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
