# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::SQL::ClubImporter;
use strict;
$Bivio::SQL::ClubImporter::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::SQL::ClubImporter - easyware data importer

=head1 SYNOPSIS

    use Bivio::SQL::ClubImporter;

=cut

use Bivio::UNIVERSAL;
@Bivio::SQL::ClubImporter::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::SQL::ClubImporter> imports easyware data in three steps:
member info, instrument info, and transactions.

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::Agent::TestRequest;
use Bivio::Biz::PropertyModel::AccountEntry;
use Bivio::Biz::PropertyModel::ClubInstrumentEntry;
use Bivio::Biz::PropertyModel::Entry;
use Bivio::Biz::PropertyModel::MemberEntry;
use Bivio::Biz::PropertyModel::Transaction;
use Bivio::IO::Trace;
use Bivio::Type::EntryClass;
use Bivio::Type::EntryType;
use Bivio::Type::TaxCategory;
use Data::Dumper ();
use Time::Local;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_DELETED_ID) = 1818584091;
my($_INITIALIZED) = 0;

# easyware transaction type --> [entry type, tax category]
# the enums get compiled when an instance is first created

my($_TYPE_MAP) = {
    # Expense
    0 => ['CASH_EXPENSE', 'MISC_EXPENSE'],
    # Income
    1 => ['CASH_INCOME', 'MISC_INCOME'],
    # Interest
    2 => ['CASH_INTEREST', 'INTEREST'],
    # Dividend
    3 => ['CASH_DIVIDEND', 'DIVIDEND'],
    # Beg. Bal.
    4 => ['CASH_OPENING_BALANCE', 'NOT_TAXABLE'],
    # Trsfr From
    5 => ['CASH_TRANSFER', 'NOT_TAXABLE'],
    # Trsfr To
    6 => ['CASH_TRANSFER', 'NOT_TAXABLE'],

    # Payment
    10 => ['MEMBER_PAYMENT', 'NOT_TAXABLE'],
    # Fee
    11 => ['MEMBER_PAYMENT_FEE', 'NOT_TAXABLE'],
    # PC Contr
    12 => ['MEMBER_PAYMENT', 'NOT_TAXABLE'],
    # Withd-Cash
    13 => ['MEMBER_WITHDRAWAL_FULL_CASH', 'NOT_TAXABLE'],
    # Withd-Stock
    14 => ['MEMBER_WITHDRAWAL_FULL_STOCK', 'NOT_TAXABLE'],
    # PWith-Cash
    15 => ['MEMBER_WITHDRAWAL_PARTIAL_CASH', 'NOT_TAXABLE'],
    # PWith-Stck
    16 => ['MEMBER_WITHDRAWAL_PARTIAL_STOCK', 'NOT_TAXABLE'],
    # Withd Fee
    17 => ['MEMBER_WITHDRAWAL_FEE', 'NOT_TAXABLE'],
    # BBal Invst
    18 => ['MEMBER_OPENING_BALANCE', 'NOT_TAXABLE'],
    # BBal Earns
    19 => ['MEMBER_OPENING_EARNINGS_DISTRIBUTION', 'NOT_TAXABLE'],
    # Distr-Div
    20 => ['MEMBER_DISTRIBUTION', 'DIVIDEND'],
    # Distr-Int
    21 => ['MEMBER_DISTRIBUTION', 'INTEREST'],
    # Distr-TFI
    22 => ['MEMBER_DISTRIBUTION', 'FEDERAL_TAX_FREE_INTEREST'],
    # Distr-Stcg
    23 => ['MEMBER_DISTRIBUTION', 'SHORT_TERM_CAPITAL_GAIN'],
    # Distr-Ltcg
    24 => ['MEMBER_DISTRIBUTION', 'LONG_TERM_CAPITAL_GAIN'],
    # Distr-Inc
    25 => ['MEMBER_DISTRIBUTION', 'MISC_INCOME'],
    # Distr-Exp
    26 => ['MEMBER_DISTRIBUTION', 'MISC_EXPENSE'],
    # Distr-ForT
    27 => ['MEMBER_DISTRIBUTION', 'FOREIGN_TAX'],
    # WDist-Div
    28 => ['MEMBER_WITHDRAWAL_DISTRIBUTION', 'DIVIDEND'],
    # WDist-Int
    29 => ['MEMBER_WITHDRAWAL_DISTRIBUTION', 'INTEREST'],
    # WDist-TFI
    30 => ['MEMBER_WITHDRAWAL_DISTRIBUTION', 'FEDERAL_TAX_FREE_INTEREST'],
    # WDist-Stcg
    31 => ['MEMBER_WITHDRAWAL_DISTRIBUTION', 'SHORT_TERM_CAPITAL_GAIN'],
    # WDist-Ltcg
    32 => ['MEMBER_WITHDRAWAL_DISTRIBUTION', 'LONG_TERM_CAPITAL_GAIN'],
    # WDist-Inc
    33 => ['MEMBER_WITHDRAWAL_DISTRIBUTION', 'MISC_INCOME'],
    # WDist-Exp
    34 => ['MEMBER_WITHDRAWAL_DISTRIBUTION', 'MISC_EXPENSE'],
    # WDist-ForT
    35 => ['MEMBER_WITHDRAWAL_DISTRIBUTION', 'FOREIGN_TAX'],
    # Distr-Itcg
    36 => ['MEMBER_DISTRIBUTION', 'MEDIUM_TERM_CAPITAL_GAIN'],
    # WDist-Itcg
    37 => ['MEMBER_WITHDRAWAL_DISTRIBUTION', 'MEDIUM_TERM_CAPITAL_GAIN'],

    # Buy
    40 => ['INSTRUMENT_BUY', 'NOT_TAXABLE'],
    # Comm-Buy
    41 => ['INSTRUMENT_BUY_COMMISSION', 'NOT_TAXABLE'],
    # Fee-Buy
    42 => ['INSTRUMENT_BUY_FEE', 'MISC_EXPENSE'],
    # Sell
    43 => ['INSTRUMENT_SELL', 'NOT_TAXABLE'],
    # Transfer
    44 => ['INSTRUMENT_TRANSFER', 'NOT_TAXABLE'],
    # Stcg-Sell
    45 => ['INSTRUMENT_SELL', 'SHORT_TERM_CAPITAL_GAIN'],
    # Ltcg-Sell
    46 => ['INSTRUMENT_SELL', 'LONG_TERM_CAPITAL_GAIN'],
    # Exp-Sell
    47 => ['INSTRUMENT_SELL', 'NOT_TAXABLE'],
    # Div-Cash
    48 => ['INSTRUMENT_DISTRIBUTION_CASH', 'DIVIDEND'],
    # Int-Cash
    49 => ['INSTRUMENT_DISTRIBUTION_CASH', 'INTEREST'],
    # Stcg-Cash
    50 => ['INSTRUMENT_DISTRIBUTION_CASH', 'SHORT_TERM_CAPITAL_GAIN'],
    # Ltcg-Cash
    51 => ['INSTRUMENT_DISTRIBUTION_CASH', 'LONG_TERM_CAPITAL_GAIN'],
    # RetCp-Cash
    52 => ['INSTRUMENT_DISTRIBUTION_RETURN_OF_CAPITAL', 'NOT_TAXABLE'],
    # Div-Inv
    53 => ['INSTRUMENT_DISTRIBUTION_INVESTMENT', 'DIVIDEND'],
    # Int-Inv
    54 => ['INSTRUMENT_DISTRIBUTION_INVESTMENT', 'INTEREST'],
    # Stcg-Inv
    55 => ['INSTRUMENT_DISTRIBUTION_INVESTMENT', 'SHORT_TERM_CAPITAL_GAIN'],
    # Ltcg-Inv
    56 => ['INSTRUMENT_DISTRIBUTION_INVESTMENT', 'LONG_TERM_CAPITAL_GAIN'],
    # RetCp-Inv
    57 => ['INSTRUMENT_DISTRIBUTION_RETURN_OF_CAPITAL', 'NOT_TAXABLE'],
    # Fee-DivInv
    58 => ['INSTRUMENT_DISTRIBUTION_INVESTMENT_FEE', 'MISC_EXPENSE'],
    # Fee-IntInv
    59 => ['INSTRUMENT_DISTRIBUTION_INVESTMENT_FEE', 'MISC_EXPENSE'],
    # Fee-StcInv
    60 => ['INSTRUMENT_DISTRIBUTION_INVESTMENT_FEE', 'MISC_EXPENSE'],
    # Fee-LtcInv
    61 => ['INSTRUMENT_DISTRIBUTION_INVESTMENT_FEE', 'MISC_EXPENSE'],
    # Fee-RtcInv
    62 => ['INSTRUMENT_DISTRIBUTION_INVESTMENT_FEE', 'MISC_EXPENSE'],
    # Split
    63 => ['INSTRUMENT_SPLIT', 'NOT_TAXABLE'],
    # SpFr-Cost
    64 => ['INSTRUMENT_SPLIT_SHARES_AS_CASH', 'NOT_TAXABLE'],
    # SpFr-Stcg
    65 => ['INSTRUMENT_SPLIT_SHARES_AS_CASH', 'SHORT_TERM_CAPITAL_GAIN'],
    # SpFr-Ltcg
    66 => ['INSTRUMENT_SPLIT_SHARES_AS_CASH', 'LONG_TERM_CAPITAL_GAIN'],
    # StkDiv-New
    67 => ['INSTRUMENT_SPINOFF', 'NOT_TAXABLE'],
    # StkDiv-Old
    68 => ['INSTRUMENT_SPINOFF', 'NOT_TAXABLE'],
    # SDFr-Cost
    69 => ['INSTRUMENT_SPINOFF_SHARES_AS_CASH', 'NOT_TAXABLE'],
    # SDFr-Stcg
    70 => ['INSTRUMENT_SPINOFF_SHARES_AS_CASH', 'SHORT_TERM_CAPITAL_GAIN'],
    # SDFr-Ltcg
    71 => ['INSTRUMENT_SPINOFF_SHARES_AS_CASH', 'LONG_TERM_CAPITAL_GAIN'],
    # Merger-Add
    72 => ['INSTRUMENT_MERGER', 'NOT_TAXABLE'],
    # Merger-Cls
    73 => ['INSTRUMENT_MERGER', 'NOT_TAXABLE'],
    # MrgFt-Cost
    74 => ['INSTRUMENT_MERGER_SHARES_AS_CASH', 'NOT_TAXABLE'],
    # MrgFt-Stcg
    75 => ['INSTRUMENT_MERGER_SHARES_AS_CASH', 'SHORT_TERM_CAPITAL_GAIN'],
    # MrgFt-Ltcg
    76 => ['INSTRUMENT_MERGER_SHARES_AS_CASH', 'LONG_TERM_CAPITAL_GAIN'],
#TODO: need to handle this case
    # For Tax
    77 => ['UNKNOWN', 'UNKNOWN'],
    # Pd By Comp
    78 => ['INSTRUMENT_DISTRIBUTION_CHARGES_PAID_BY_COMPANY', 'NOT_TAXABLE'],
    # Beg Bal
    79 => ['INSTRUMENT_OPENING_BALANCE', 'NOT_TAXABLE'],
#TODO: need to handle this case
    # Div-ForTax
    80 => ['UNKNOWN', 'UNKNOWN'],

    # DivInvComm
    92 => ['INSTRUMENT_DISTRIBUTION_INVESTMENT_COMMISSION', 'NOT_TAXABLE'],
    # IntInvComm
    93 => ['INSTRUMENT_DISTRIBUTION_INVESTMENT_COMMISSION', 'NOT_TAXABLE'],
    # StcInvComm
    94 => ['INSTRUMENT_DISTRIBUTION_INVESTMENT_COMMISSION', 'NOT_TAXABLE'],
    # LtcInvComm
    95 => ['INSTRUMENT_DISTRIBUTION_INVESTMENT_COMMISSION', 'NOT_TAXABLE'],
    # RtCpIvComm
    96 => ['INSTRUMENT_DISTRIBUTION_INVESTMENT_COMMISSION', 'NOT_TAXABLE'],
    # Mtcg-Sell
    97 => ['INSTRUMENT_SELL', 'MEDIUM_TERM_CAPITAL_GAIN'],
    # Mtcg-Cash
    98 => ['INSTRUMENT_DISTRIBUTION_CASH', 'MEDIUM_TERM_CAPITAL_GAIN'],
    # Mtcg-Inv
    99 => ['INSTRUMENT_DISTRIBUTION_INVESTMENT', 'MEDIUM_TERM_CAPITAL_GAIN'],
    # MtcInvComm
    100 => ['INSTRUMENT_DISTRIBUTION_INVESTMENT_COMMISSION', 'NOT_TAXABLE'],
    # Fee-MtcInv
    101 => ['INSTRUMENT_DISTRIBUTION_INVESTMENT_FEE', 'MISC_EXPENSE'],

#TODO: SpFr-Mtcg, SDFr-Mtcg, MrgFr-Mtcg
};

# created from the set below at runtime, keyed by transaction type
my($_TRANSACTION_SET_MAP) = {};

# implicit easyware transaction entry sets
my($_TRANSACTION_SETS) = [
	# note: cash payment source 0 is all payments on date (multiple)
	[10],
	# transfer from/to
	[5,6],
	# member withdraw
	[13, 14, 15, 16, 17, 28, 29, 30, 31, 32, 33, 34, 35, 37],
	# member distribution
	[20, 21, 22, 23, 24, 25, 26, 27, 36],
	# buy
	[40, 41, 42],
	# sell
	[43, 45, 46, 47, 97],
	# reinvested distribution, dividend
	[53, 58, 92],
	# reinvested distribution, interest
	[54, 59, 93],
	# reinvested distribution, short term gain
	[55, 60, 94],
	# reinvested distribution, long term gain
	[56, 61, 95],
	# reinvested distribution, return of capital
	[57, 62, 96],
	# reinvested distribution, mid term gain
	[99, 100, 101],
	# stock split
#TODO: add SpFr-Mtcg
	[63, 64, 65, 66],
	# spinoff
#TODO: add SDFr-Mtcg
	[67, 68, 69, 70, 71],
	# merger
#TODO: add MrgFr-Mtcg
	[72, 73, 74, 75, 76],
	# foreign taxes
	[77, 80],
       ];

# easyware data formats

my($_MEMBER_FORMAT) = {
    file_name => 'member.dt',
    data_start => 1274,
    fields => [
	    'member_id', 'int2',
	    'last_name', 'string21',
	    'first_name', 'string26',
	    'address', 'string31',
	    'unknown-1', 'byte10',
	    'city', 'string21',
	    'state', 'string3',
	    'zip', 'string12',
	    'home_phone', 'string18',
	    'work_phone', 'string18',
	    'contact', 'string31',
	    'ssn', 'string12',
	    'active', 'boolean2',
	    'unknown-2', 'byte60',
	   ],
};

my($_MEMBER_TRANSACTION_FORMAT) = {
    file_name => 'memtrans.dt',
    data_start => 1274,
    fields => [
	    'member_id', 'int2',
	    'dttm', 'date2',
	    'transaction_type', 'int2',
	    'amount', 'double8',
	    'units', 'double8',
	    'remark', 'string30',
	   ],
};

my($_CASH_TRANSACTION_FORMAT) = {
    file_name => 'cash.dt',
    data_start => 1274,
    fields => [
	    'dttm', 'date2',
	    'transaction_type', 'int2',
	    'source_id', 'int2',
	    'account_type', 'int2',
	    'amount', 'double8',
	    'remark', 'string31',
	    'unknown', 'byte1',
	   ],
};

my($_INSTRUMENT_FORMAT) = {
    file_name => 'secname.dt',
    data_start => 1274,
    fields => [
	    'instrument_id', 'int2',
	    'instrument_name', 'string31',
	    'account_number', 'string16',
	    'remark', 'string31',
	    'instrument_type', 'int2',
	    'active', 'boolean2',
	    'fed_tax_free', 'boolean2',
	    'average_cost_method', 'boolean2',
	    'drp_plan', 'boolean2',
	    'ticker_symbol', 'string8',
	    'unknown', 'byte50',
	   ],
};

my($_INSTRUMENT_TRANSACTION_FORMAT) = {
    file_name => 'security.dt',
    data_start => 1274,
    fields => [
	    'instrument_id', 'int2',
	    'dttm', 'date2',
	    'transaction_type', 'int2',
	    'shares', 'double8',
	    'amount', 'double8',
	    'remark', 'string30',
	    'block', 'int2',
	   ],
};

my($_VALUATION_FORMAT) = {
    file_name => 'valuatn.dt',
    data_start => 1274,
    fields => [
	    'dttm', 'date2',
	    'instrument_id', 'int2',
	    'price_per_share', 'double8',
	   ],
};

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string data_file_directory) : Bivio::SQL::ClubImporter

Creates a ClubImporter which will look in the specified directory for
easyware data files.

=cut

sub new {
    my($proto, $data_file_directory) = @_;
    my($self) = &Bivio::UNIVERSAL::new($proto);
    $self->{$_PACKAGE} = {
	directory => $data_file_directory,
    };

    if (! $_INITIALIZED) {
	$_INITIALIZED = 1;
	_compile_type_map();
	_create_transaction_set_map();
    }
    return $self;
}

=head1 METHODS

=cut

=for html <a name="import_members"></a>

=head2 import_members(hash attributes) : hash

Imports member information from the easyware data files. Loads the
user_t, user_pref_t, user_email_t tables.

Attributes:

   {
      club_id => <id>,            # the target club's id
      email_map => {              # map of user_id to email addresses
         <easyware_id> => <primary_user_email>,
         ...
         },
   }

Result:

   {
      club_id => <id>,            # the target club's id
      member_id_map => {          # easyware id to user id map
         <easyware_id> => <user_id>,
         ...
         },
   }

=cut

sub import_members {
    my($self, $attributes) = @_;
    my($fields) = $self->{$_PACKAGE};

    die("not implemented");
}

=for html <a name="import_securities"></a>

=head2 import_instruments(hash attributes) : hash

Imports instrument information from easyware data files. Loads the
club_instrument_t and club_instrument_valuation_t tables.

Attributes:

   {
      club_id => <id>,            # the target club's id
   }

Result:

   {
      club_id => <id>,            # the target club's id
      instrument_id_map => {      # easyware id to instrument id map
         <easyware_id> => <club_instrument_id>,
         ...
         },
   }

=cut

sub import_securities {
    my($self, $attributes) = @_;
    my($fields) = $self->{$_PACKAGE};

    die("not implemented");
}

=for html <a name="import_transactions"></a>

=head2 import_transactions(hash attributes)

Imports member, instrument, and cash transactions from easyware data files.
Loads the entry_t, member_entry_t, instrument_entry_t, account_entry_t,
account_t, and transaction_t tables.

Attributes:

   {
      club_id => <id>,            # the target club's id
      member_id_map => {          # easyware id to user id map
         <easyware_id> => <user_id>,
         ...
         },
      instrument_id_map => {      # easyware id to instrument id map
         <easyware_id> => <club_instrument_id>,
         ...
         },
      accounts => {               # societas predefined journal accounts
         bank => <bank account id>,
         broker => <broker account id>,
         suspense => <suspense account id>,
         investment => <investment account id>,
         member => <member paid account id>,
         dividend => <dividend account id>,
         interest => <interest account id>,
         misc => <misc account id>,
         gain => <gain on sales account id>,
         unrealized_gain => <unrealized gain account id>,
         petty_cash => <petty cash account id>,
         },
   }

=cut

sub import_transactions {
    my($self, $attributes) = @_;

    my($member_trans) = _parse_file($self, $_MEMBER_TRANSACTION_FORMAT);
    my($instrument_trans) = _parse_file($self,
	    $_INSTRUMENT_TRANSACTION_FORMAT);
    my($cash_trans) = _parse_file($self, $_CASH_TRANSACTION_FORMAT);

    my($req) = Bivio::Agent::TestRequest->new({});
    my($transaction) = Bivio::Biz::PropertyModel::Transaction->new($req);
    my($entry) = Bivio::Biz::PropertyModel::Entry->new($req);
    my($member_entry) = Bivio::Biz::PropertyModel::MemberEntry->new($req);
    my($instrument_entry) =
	    Bivio::Biz::PropertyModel::ClubInstrumentEntry->new($req);
    my($account_entry) = Bivio::Biz::PropertyModel::AccountEntry->new($req);

#TODO: link transactions properly
    # for now all one transaction!
    $transaction->create({
	club_id => $attributes->{club_id},
	source_class => Bivio::Type::EntryClass->MEMBER->as_int(),
	dttm => 870436800,
	remark => 'a really big transaction',
	});

#=begin

    # member transactions
    foreach (@$member_trans) {
	_create_entry($entry, $transaction, Bivio::Type::EntryClass->MEMBER,
		$_);
	$member_entry->create({
	    entry_id => $entry->get('entry_id'),
	    user_id => $attributes->{member_id_map}->{$_->{member_id}},
	    units => $_->{units}
	    });
    }

    # instrument transactions
    foreach (@$instrument_trans) {
	_create_entry($entry, $transaction,
		Bivio::Type::EntryClass->INSTRUMENT, $_);
	$instrument_entry->create({
	    entry_id => $entry->get('entry_id'),
	    instrument_id => $attributes->{instrument_id_map}->{
		$_->{instrument_id}},
	    shares => $_->{shares},
	    block => $_->{block},
	    });

	_create_account_entry($account_entry, $entry,
		$entry->get('tax_category'), $attributes);
    }

#=cut

    # cash transactions
    foreach (@$cash_trans) {
	
    }
}

#=PRIVATE METHODS

# _create_account_entry(AccountEntry account_entry, Entry entry, TaxCategory tax_category, hash_ref accounts)
#
# Creates an account entry for the specified values

sub _create_account_entry {
    my($account_entry, $entry, $tax_category, $accounts) = @_;

    my($account_id);
    if ($tax_category == Bivio::Type::TaxCategory->DIVIDEND) {

	$account_id = $accounts->{dividend};

    } elsif ($tax_category == Bivio::Type::TaxCategory->INTEREST
	    or $tax_category
	    == Bivio::Type::TaxCategory->FEDER_TAX_FREE_INTEREST) {

	$account_id = $accounts->{interest};

    } elsif ($tax_category
	    == Bivio::Type::TaxCategory->SHORT_TERM_CAPITAL_GAIN
	    or $tax_category
	    == Bivio::Type::TaxCategory->MEDIUM_TERM_CAPITAL_GAIN
	    or $tax_category
	    == Bivio::Type::TaxCategory->LONG_TERM_CAPITAL_GAIN) {

	$account_id = $accounts->{gain};

    } elsif ($tax_category
	    == Bivio::Type::TaxCategory->FOREIGN_TAX
	    or $tax_category
	    == Bivio::Type::TaxCategory->MISC_INCOME
	    or $tax_category
	    == Bivio::Type::TaxCategory->MISC_EXPENSE) {

	$account_id = $accounts->{misc};

    } else {

	die("can't create default account entry for $tax_category");
    }

    $account_entry->create({
	entry_id => $entry->get('entry_id'),
	account_id => $account_id,
    });
}

# _create_entry(Entry entry, Transaction transaction_id EntryClass class, hash_ref values)
#
# Creates the entry with the specified class and values.

sub _create_entry {
    my($entry, $transaction, $class, $values) = @_;

    $entry->create({
	transaction_id => $transaction->get('transaction_id'),
	class => $class->as_int(),
	entry_type => $_TYPE_MAP->{$values->{transaction_type}}->[0]->as_int(),
	tax_category => $_TYPE_MAP->{
	    $values->{transaction_type}}->[1]->as_int(),
	amount => $values->{amount},
	remark => $values->{remark},
    });
}

# _compile_type_map()
#
# replaces the string constants in _TYPE_MAP with the corresponding enum

sub _compile_type_map {

    foreach (keys(%$_TYPE_MAP)) {
	my($entry_type) = $_TYPE_MAP->{$_}->[0];
	my($tax_category) = $_TYPE_MAP->{$_}->[1];

	$_TYPE_MAP->{$_}->[0] = eval("Bivio::Type::EntryType->$entry_type");
	$@ && die($@);
	$_TYPE_MAP->{$_}->[1] =
		eval("Bivio::Type::TaxCategory->$tax_category");
	$@ && die($@);
    }
}

# _create_transaction_set_map()
#
# creates the _TRANSACTION_SET_MAP hash using values from
# _TRANSACTION_SETS

sub _create_transaction_set_map {

    my($set);
    foreach $set (@$_TRANSACTION_SETS) {
	foreach (@$set) {
	    die("transaction $_ in multiple sets") if exists(
		    $_TRANSACTION_SET_MAP->{$_});
	    $_TRANSACTION_SET_MAP->{$_} = $set;
	}
    }
}

# _parse_file(hash_ref format) : array_ref
#
# Parses the file and returns an array of hashed records.

sub _parse_file {
    my($self, $format) = @_;
    my($result) = [];

    my($file_name) = $self->{$_PACKAGE}->{directory}.'/'.$format->{file_name};
    open(IN, '< '.$file_name) || die("can't open file $file_name");
    binmode(IN); # for win32

    my($fields) = $format->{fields};

    # determine the record size from the field types
    my($record_size) = 0;
    for (my($i) = 0; $i < int(@$fields); $i += 2 ) {
	$fields->[$i + 1] =~ /^\D*(.*)$/;
	$record_size += $1;
    }

    my($reading) = 0;

    eval {
	# advance to record start
	_read_bytes(*IN, $format->{data_start});

	while (1) {

	    # see if the record has been deleted
	    my($record_id) = _read_int4(*IN);
	    if ($record_id == $_DELETED_ID) {
		_read_bytes(*IN, $record_size);
		next;
	    }

	    $reading = 1;
	    my($record) = {};

	    for (my($i) = 0; $i < int(@$fields); $i += 2) {
		my($name) = $fields->[$i];
		my($type) = $fields->[$i + 1];

		if ($type eq 'int2') {
		    $record->{$name} = _read_int2(*IN);
		}
		elsif ($type eq 'boolean2') {
		    $record->{$name} = _read_boolean(*IN);
		}
		elsif ($type eq 'date2') {
		    $record->{$name} = _read_date(*IN);
		}
		elsif ($type eq 'double8') {
		    $record->{$name} = _read_double(*IN);
		}
		elsif ($type =~ /^string(.*)$/) {
		    $record->{$name} = _read_string(*IN, $1);
		}
		elsif ($type =~ /^byte(.*)$/) {
		    $record->{$name} = _read_bytes(*IN, $1);
		    # remove it for now
		    delete($record->{$name});
		}
		else {
		    die('unknown type '.$type);
		}
	    }
	    $reading = 0;
	    push(@$result, $record);
	}
    };
    close(IN) || die("couldn't close $file_name");

    # check for exception during read
    die($@) unless ($@ =~ /^end of input/) && ! $reading;

    if ($_TRACE) {
	foreach (@$result) {
	    _trace(Data::Dumper->Dumper($_));
	}
    }

    return $result;
}

#WARNING:
#
# all read methods depend on byte order of i86 platform
#

# _read_boolean(file) : int
#
# Read and returns a two byte boolean.

sub _read_boolean {
    my($file) = @_;

    my($value) = _read_int2($file);
    die('invalid boolean '.$value) unless ($value == 0 or $value == 1);

    _trace("boolean $value") if $_TRACE;
    return $value;
}

# _read_types(file, length) : string
#
# Reads and returns the specified number of bytes.

sub _read_bytes {
    my($file, $length) = @_;

    my($bytes);
    read(*$file, $bytes, $length) || die('end of input');

    return $bytes;
}

# _read_date(file) : string
#
# Reads and returns the next date value.

sub _read_date {
    my($file) = @_;

    # format:
    #   Bytes    xxxx     xxx|x     xxx|x    xxxx
    #            year offset  month     day

    my($packed_date) = _read_int2($file);
    my($day) = $packed_date & 0x1f;
    my($month) = ($packed_date >> 5) & 0x0f;
    my($year_offset) = ($packed_date >> 9) & 0x7f;
    my($year) = 1980 + $year_offset;

    # check if it is past century split
    if ($year > 2043) {
	$year -= 100;
    }
    my($value) = Time::Local::timegm(0, 0, 12, $day, $month - 1, $year);

    _trace("date $value") if $_TRACE;
    return $value;
}

# _read_double(file) : string
#
# Reads and returns an 8 byte double.

sub _read_double {
    my($file) = @_;

    my($value) = unpack('d', _read_bytes($file, 8));

    _trace("double $value") if $_TRACE;
    return $value;
}

# _read_in2(file) : int
#
# Reads and returns a two byte integer.

sub _read_int2 {
    my($file) = @_;

    my($value) = unpack('s', _read_bytes($file, 2));

    _trace("int $value") if $_TRACE;
    return $value;
}

# _read_int4(file) : int
#
# Reads and returns a four byte integer.

sub _read_int4 {
    my($file) = @_;

    my($value) = unpack('i', _read_bytes($file, 4));

    _trace("int4 $value") if $_TRACE;
    return $value;
}

# _read_string(file, length) : string
#
# Reads and returns the next string data value.

sub _read_string {
    my($file, $length) = @_;

    my($value) = _read_bytes($file, $length);

    # trim after the first null
    $value = substr($value, 0, index($value, "\0"));

    _trace("string '$value'") if $_TRACE;
    return $value;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
