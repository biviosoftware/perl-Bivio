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
use Bivio::Biz::PropertyModel::InstrumentEntry;
use Bivio::Biz::PropertyModel::Entry;
use Bivio::Biz::PropertyModel::MemberEntry;
use Bivio::Biz::PropertyModel::Transaction;
use Bivio::IO::Trace;
use Bivio::SQL::Connection;
use Bivio::Type::EntryClass;
use Bivio::Type::EntryType;
use Bivio::Type::TaxCategory;
use Data::Dumper ();
use Time::Local ();

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_DELETED_ID) = 1818584091;
my($_INITIALIZED) = 0;

# easyware transaction type --> [entry type, tax category, transaction id]
# the enums get compiled when an instance is first created.
# a transaction id of 0 indicates a unary transaction.

my($_TYPE_MAP) = {
    # Expense
    0 => ['CASH_EXPENSE', 'MISC_EXPENSE',
	    0, '-cash', '+misc'],
    # Income
    1 => ['CASH_INCOME', 'MISC_INCOME',
	    0, '-misc', '+cash'],
    # Interest
    2 => ['CASH_INTEREST', 'INTEREST',
	    0, '-interest', '+cash'],
    # Dividend
    3 => ['CASH_DIVIDEND', 'DIVIDEND',
	    0, '-dividend', '+cash'],
    # Beg. Bal.
    4 => ['CASH_OPENING_BALANCE', 'NOT_TAXABLE',
	    0, '+cash', ''],
    # Trsfr From
    5 => ['CASH_TRANSFER', 'NOT_TAXABLE',
	    1, '-cash', ''],
    # Trsfr To
    6 => ['CASH_TRANSFER', 'NOT_TAXABLE',
	    1, '+cash', ''],

    # Payment
    10 => ['MEMBER_PAYMENT', 'NOT_TAXABLE',
	    0, '-member', '+cash'],
    # Fee
    11 => ['MEMBER_PAYMENT_FEE', 'NOT_TAXABLE',
	    0, '-member', '+cash'],
    # PC Contr
    12 => ['MEMBER_PAYMENT', 'NOT_TAXABLE',
	    0, '-member', '+cash'],
    # Withd-Cash
    13 => ['MEMBER_WITHDRAWAL_FULL_CASH', 'NOT_TAXABLE',
	    2, '-cash', '+member',],
    # Withd-Stock
    14 => ['MEMBER_WITHDRAWAL_FULL_STOCK', 'NOT_TAXABLE',
	    2, '-investment', '+member'],
    # PWith-Cash
    15 => ['MEMBER_WITHDRAWAL_PARTIAL_CASH', 'NOT_TAXABLE',
	    2, '-cash', '+member'],
    # PWith-Stck
    16 => ['MEMBER_WITHDRAWAL_PARTIAL_STOCK', 'NOT_TAXABLE',
	    2, '-investment', '+member'],
    # Withd Fee
    17 => ['MEMBER_WITHDRAWAL_FEE', 'NOT_TAXABLE',
	    2, '-member', '+cash'],
    # BBal Invst
    18 => ['MEMBER_OPENING_BALANCE', 'NOT_TAXABLE',
	    0, '-member', ''],
    # BBal Earns
    19 => ['MEMBER_OPENING_EARNINGS_DISTRIBUTION', 'NOT_TAXABLE',
	    0, '-member', ''],
    # Distr-Div
    20 => ['MEMBER_DISTRIBUTION', 'DIVIDEND',
	    3, '-dividend', '+member'],
    # Distr-Int
    21 => ['MEMBER_DISTRIBUTION', 'INTEREST',
	    3, '-interest', '+member'],
    # Distr-TFI
    22 => ['MEMBER_DISTRIBUTION', 'FEDERAL_TAX_FREE_INTEREST',
	    3, '-interest', '+member'],
    # Distr-Stcg
    23 => ['MEMBER_DISTRIBUTION', 'SHORT_TERM_CAPITAL_GAIN',
	    3, '-gain', '+member'],
    # Distr-Ltcg
    24 => ['MEMBER_DISTRIBUTION', 'LONG_TERM_CAPITAL_GAIN',
	    3, '-gain', '+member'],
    # Distr-Inc
    25 => ['MEMBER_DISTRIBUTION', 'MISC_INCOME',
	    3, '-misc', '+member'],
    # Distr-Exp
    26 => ['MEMBER_DISTRIBUTION', 'MISC_EXPENSE',
	    3, '-misc', '+member'],
    # Distr-ForT
    27 => ['MEMBER_DISTRIBUTION', 'FOREIGN_TAX',
	    3, '-dividend', '+member'],
    # WDist-Div
    28 => ['MEMBER_WITHDRAWAL_DISTRIBUTION', 'DIVIDEND',
	    2, '-dividend', '+member'],
    # WDist-Int
    29 => ['MEMBER_WITHDRAWAL_DISTRIBUTION', 'INTEREST',
	    2, '-interest', '+member'],
    # WDist-TFI
    30 => ['MEMBER_WITHDRAWAL_DISTRIBUTION', 'FEDERAL_TAX_FREE_INTEREST',
	    2, '-interest', '+member'],
    # WDist-Stcg
    31 => ['MEMBER_WITHDRAWAL_DISTRIBUTION', 'SHORT_TERM_CAPITAL_GAIN',
	    2, '-gain', '+member'],
    # WDist-Ltcg
    32 => ['MEMBER_WITHDRAWAL_DISTRIBUTION', 'LONG_TERM_CAPITAL_GAIN',
	    2, '-gain', '+member'],
    # WDist-Inc
    33 => ['MEMBER_WITHDRAWAL_DISTRIBUTION', 'MISC_INCOME',
	    2, '-misc', '+member'],
    # WDist-Exp
    34 => ['MEMBER_WITHDRAWAL_DISTRIBUTION', 'MISC_EXPENSE',
	    2, '-misc', '+member'],
    # WDist-ForT
    35 => ['MEMBER_WITHDRAWAL_DISTRIBUTION', 'FOREIGN_TAX',
	    2, '-dividend', '+member'],
    # Distr-Itcg
    36 => ['MEMBER_DISTRIBUTION', 'MEDIUM_TERM_CAPITAL_GAIN',
	    3, '-gain', '+member'],
    # WDist-Itcg
    37 => ['MEMBER_WITHDRAWAL_DISTRIBUTION', 'MEDIUM_TERM_CAPITAL_GAIN',
	    2, '-gain', '+member'],

    # Buy
    40 => ['INSTRUMENT_BUY', 'NOT_TAXABLE',
	    4, '-cash', '+investment'],
    # Comm-Buy
    41 => ['INSTRUMENT_BUY_COMMISSION', 'NOT_TAXABLE',
	    4, '-cash', '+intstrument'],
    # Fee-Buy
    42 => ['INSTRUMENT_BUY_FEE', 'MISC_EXPENSE',
	    4, '-cash', '+misc'],
    # Sell
    43 => ['INSTRUMENT_SELL', 'NOT_TAXABLE',
	    5, '-investment', '+cash'],
    # Transfer
    44 => ['INSTRUMENT_TRANSFER', 'NOT_TAXABLE',
	    0, '-investment', '+member'],
    # Stcg-Sell
    45 => ['INSTRUMENT_SELL', 'SHORT_TERM_CAPITAL_GAIN',
	    5, '+cash', '+gain'],
    # Ltcg-Sell
    46 => ['INSTRUMENT_SELL', 'LONG_TERM_CAPITAL_GAIN',
	    5, '+cash', '+gain'],
    # Exp-Sell
    47 => ['INSTRUMENT_SELL', 'NOT_TAXABLE',
	    5, '-investment', '+cash'],
    # Div-Cash
    48 => ['INSTRUMENT_DISTRIBUTION_CASH', 'DIVIDEND',
	    0, '+cash', '+dividend'],
    # Int-Cash
    49 => ['INSTRUMENT_DISTRIBUTION_CASH', 'INTEREST',
	    0, '+cash', '+interest'],
    # Stcg-Cash
    50 => ['INSTRUMENT_DISTRIBUTION_CASH', 'SHORT_TERM_CAPITAL_GAIN',
	    0, '+cash', '+gain'],
    # Ltcg-Cash
    51 => ['INSTRUMENT_DISTRIBUTION_CASH', 'LONG_TERM_CAPITAL_GAIN',
	    0, '+cash', '+gain'],
    # RetCp-Cash
    52 => ['INSTRUMENT_DISTRIBUTION_RETURN_OF_CAPITAL', 'NOT_TAXABLE',
	    0, '-investment', '+cash'],
    # Div-Inv
    53 => ['INSTRUMENT_DISTRIBUTION_INVESTMENT', 'DIVIDEND',
	    6, '+cash', '+dividend'],
    # Int-Inv
    54 => ['INSTRUMENT_DISTRIBUTION_INVESTMENT', 'INTEREST',
	    7, '+investment', '+interest'],
    # Stcg-Inv
    55 => ['INSTRUMENT_DISTRIBUTION_INVESTMENT', 'SHORT_TERM_CAPITAL_GAIN',
	    8, '+investment', '+gain'],
    # Ltcg-Inv
    56 => ['INSTRUMENT_DISTRIBUTION_INVESTMENT', 'LONG_TERM_CAPITAL_GAIN',
	    9, '+investment', '+gain'],
#TODO: this is a weird case - from investment to investment?
    # RetCp-Inv
    57 => ['INSTRUMENT_DISTRIBUTION_RETURN_OF_CAPITAL', 'NOT_TAXABLE',
	    10, '-investment', '+cash'],
    # Fee-DivInv
    58 => ['INSTRUMENT_DISTRIBUTION_INVESTMENT_FEE', 'MISC_EXPENSE',
	    6, '-cash', '+misc'],
    # Fee-IntInv
    59 => ['INSTRUMENT_DISTRIBUTION_INVESTMENT_FEE', 'MISC_EXPENSE',
	    7, '-cash', '+misc'],
    # Fee-StcInv
    60 => ['INSTRUMENT_DISTRIBUTION_INVESTMENT_FEE', 'MISC_EXPENSE',
	    8, '-cash', '+misc'],
    # Fee-LtcInv
    61 => ['INSTRUMENT_DISTRIBUTION_INVESTMENT_FEE', 'MISC_EXPENSE',
	    9, '-cash', '+misc'],
    # Fee-RtcInv
    62 => ['INSTRUMENT_DISTRIBUTION_INVESTMENT_FEE', 'MISC_EXPENSE',
	    10, '-cash', '+misc'],
    # Split
    63 => ['INSTRUMENT_SPLIT', 'NOT_TAXABLE',
	    12, '', ''],
    # SpFr-Cost
    64 => ['INSTRUMENT_SPLIT_SHARES_AS_CASH', 'NOT_TAXABLE',
	    12, '+cash', '-investment'],
    # SpFr-Stcg
    65 => ['INSTRUMENT_SPLIT_SHARES_AS_CASH', 'SHORT_TERM_CAPITAL_GAIN',
	    12, '+cash', '+gain'],
    # SpFr-Ltcg
    66 => ['INSTRUMENT_SPLIT_SHARES_AS_CASH', 'LONG_TERM_CAPITAL_GAIN',
	    12, '+cash', 'gain'],
    # StkDiv-New
    67 => ['INSTRUMENT_SPINOFF', 'NOT_TAXABLE',
	    13, '', ''],
    # StkDiv-Old
    68 => ['INSTRUMENT_SPINOFF', 'NOT_TAXABLE',
	    13, '', ''],
    # SDFr-Cost
    69 => ['INSTRUMENT_SPINOFF_SHARES_AS_CASH', 'NOT_TAXABLE',
	    13, '+cash', '-investment'],
    # SDFr-Stcg
    70 => ['INSTRUMENT_SPINOFF_SHARES_AS_CASH', 'SHORT_TERM_CAPITAL_GAIN',
	    13, '+cash', '+gain'],
    # SDFr-Ltcg
    71 => ['INSTRUMENT_SPINOFF_SHARES_AS_CASH', 'LONG_TERM_CAPITAL_GAIN',
	    13, '+cash', '+gain'],
    # Merger-Add
    72 => ['INSTRUMENT_MERGER', 'NOT_TAXABLE',
	    14, '', ''],
    # Merger-Cls
    73 => ['INSTRUMENT_MERGER', 'NOT_TAXABLE',
	    14, '', ''],
    # MrgFt-Cost
    74 => ['INSTRUMENT_MERGER_SHARES_AS_CASH', 'NOT_TAXABLE',
	    14, '+cash', '-investment'],
    # MrgFt-Stcg
    75 => ['INSTRUMENT_MERGER_SHARES_AS_CASH', 'SHORT_TERM_CAPITAL_GAIN',
	    14, '+cash', '+gain'],
    # MrgFt-Ltcg
    76 => ['INSTRUMENT_MERGER_SHARES_AS_CASH', 'LONG_TERM_CAPITAL_GAIN',
	    14, '+cash', '+gain'],
#TODO: need to handle this case
    # For Tax
    77 => ['UNKNOWN', 'UNKNOWN',
	    15, '', ''],
    # Pd By Comp
    78 => ['INSTRUMENT_DISTRIBUTION_CHARGES_PAID_BY_COMPANY', 'NOT_TAXABLE',
	    0, '-investment', '-dividend'],
    # Beg Bal
    79 => ['INSTRUMENT_OPENING_BALANCE', 'NOT_TAXABLE',
	    0, '+investment', ''],
#TODO: need to handle this case
    # Div-ForTax
    80 => ['UNKNOWN', 'UNKNOWN',
	    15, '', ''],

    # DivInvComm
    92 => ['INSTRUMENT_DISTRIBUTION_INVESTMENT_COMMISSION', 'NOT_TAXABLE',
	    6, '', ''],
    # IntInvComm
    93 => ['INSTRUMENT_DISTRIBUTION_INVESTMENT_COMMISSION', 'NOT_TAXABLE',
	    7, '', ''],
    # StcInvComm
    94 => ['INSTRUMENT_DISTRIBUTION_INVESTMENT_COMMISSION', 'NOT_TAXABLE',
	    8, '', ''],
    # LtcInvComm
    95 => ['INSTRUMENT_DISTRIBUTION_INVESTMENT_COMMISSION', 'NOT_TAXABLE',
	    9, '', ''],
    # RtCpIvComm
    96 => ['INSTRUMENT_DISTRIBUTION_INVESTMENT_COMMISSION', 'NOT_TAXABLE',
	    10, '', ''],
    # Mtcg-Sell
    97 => ['INSTRUMENT_SELL', 'MEDIUM_TERM_CAPITAL_GAIN',
	    5, '+cash', '+gain'],
    # Mtcg-Cash
    98 => ['INSTRUMENT_DISTRIBUTION_CASH', 'MEDIUM_TERM_CAPITAL_GAIN',
	    0, '+cash', '+gain'],
    # Mtcg-Inv
    99 => ['INSTRUMENT_DISTRIBUTION_INVESTMENT', 'MEDIUM_TERM_CAPITAL_GAIN',
	    11, '+investment', '+gain'],
    # MtcInvComm
    100 => ['INSTRUMENT_DISTRIBUTION_INVESTMENT_COMMISSION', 'NOT_TAXABLE',
	    11, '', ''],
    # Fee-MtcInv
    101 => ['INSTRUMENT_DISTRIBUTION_INVESTMENT_FEE', 'MISC_EXPENSE',
	    11, '-cash', '+misc'],

#TODO: SpFr-Mtcg, SDFr-Mtcg, MrgFr-Mtcg: trans (12, 13, 14)
};

# created for the set of transactions implicitly associated with easyware
# transaction types, indexed by transaction id --> [types...].
# For example: _TRANSACTION_ID_SET[6] --> [53, 58, 92]

my($_TRANSACTION_ID_SET) = [];

# easyware data formats

my($_MEMBER_FORMAT) = {
    file_name => 'member.dt',
    data_start => 1274,
    fields => [
	    'member_id', 'int2',
	    'last_name', 'string21',
	    'first_name', 'string26',
	    'address', 'string31',
	    'UNKNOWN-1', 'byte10',
	    'city', 'string21',
	    'state', 'string3',
	    'zip', 'string12',
	    'home_phone', 'string18',
	    'work_phone', 'string18',
	    'contact', 'string31',
	    'ssn', 'string12',
	    'active', 'boolean2',
	    'UNKNOWN-2', 'byte60',
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
	    'UNKNOWN', 'byte1',
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
	    'UNKNOWN', 'byte50',
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
	_create_transaction_id_set();
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
    my($fields) = $self->{$_PACKAGE};

    my($member_trans) = _parse_file($self, $_MEMBER_TRANSACTION_FORMAT);
    my($instrument_trans) = _parse_file($self,
	    $_INSTRUMENT_TRANSACTION_FORMAT);
    my($cash_trans) = _parse_file($self, $_CASH_TRANSACTION_FORMAT);

    $fields->{member_trans} = $member_trans;
    $fields->{instrument_trans} = $instrument_trans;
    $fields->{cash_trans} = $cash_trans;

    my($trans);
    foreach $trans (@$member_trans) {

	next if (! defined($trans));

	my($dttm) = $trans->{dttm};
	my($transaction) = _create_transaction($attributes->{club_id},
		Bivio::Type::EntryClass->MEMBER, $dttm);

	_import_transactions($self, $transaction, $trans->{member_id}, $dttm,
		$trans->{transaction_type}, $attributes);
    }

    foreach $trans (@$instrument_trans) {

	next if (! defined($trans));

	my($dttm) = $trans->{dttm};
	my($transaction) = _create_transaction($attributes->{club_id},
		Bivio::Type::EntryClass->INSTRUMENT, $dttm);

	_import_transactions($self, $transaction, $trans->{instrument_id}, $dttm,
		$trans->{transaction_type}, $attributes);
    }

    foreach $trans (@$cash_trans) {

	next if (! defined($trans));

	my($dttm) = $trans->{dttm};
	my($transaction) = _create_transaction($attributes->{club_id},
		Bivio::Type::EntryClass->ACCOUNT, $dttm);

	_import_transactions($self, $transaction, $trans->{source_id}, $dttm,
		$trans->{transaction_type}, $attributes);
    }

    foreach $trans (@$member_trans) {
	die('missed transaction: '.Data::Dumper->Dumper($trans)) if (defined($trans));
    }
    foreach $trans (@$instrument_trans) {
	die('missed transaction: '.Data::Dumper->Dumper($trans)) if (defined($trans));
    }
    foreach $trans (@$cash_trans) {
	die('missed transaction: '.Data::Dumper->Dumper($trans)) if (defined($trans));
    }

    Bivio::SQL::Connection->commit();
}

#=PRIVATE METHODS

# _contains(array_ref a, scalar value) : boolean
#
# Returns 1 if the specified array contains the specified value.

sub _contains {
    my($a, $value) = @_;

    my($target);
    foreach $target (@$a) {
	return 1 if $target eq $value;
    }
    return 0;
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

# _create_transaction(ID club_id, EntryClass class, date dttm) : Transaction
#
# Creates a Bivio::Biz::PropertyModel::Transactions from the specified
# data.

sub _create_transaction {
    my($club_id, $class, $dttm) = @_;

    my($req) = Bivio::Agent::TestRequest->new({});
    my($transaction) = Bivio::Biz::PropertyModel::Transaction->new($req);

    $transaction->create({
	club_id => $club_id,
	source_class => $class->as_int(),
	dttm => $dttm,
    });

    return $transaction;
}

# _create_transaction_id_set()
#
# creates the _TRANSACTION_ID_SET array using values from _TYPE_MAP

sub _create_transaction_id_set {

    my($type);
    foreach $type (keys(%$_TYPE_MAP)) {
	my($index) = $_TYPE_MAP->{$type}->[2];

	next if $index == 0;

	if (defined($_TRANSACTION_ID_SET->[$index])) {
	    push(@{$_TRANSACTION_ID_SET->[$index]}, $type),
	}
	else {
	    $_TRANSACTION_ID_SET->[$index] = [$type];
	}
    }
    # index 0 is the empty set
    $_TRANSACTION_ID_SET->[0] = [];
}

# _parse_file(hash_ref format) : array_ref
#
# Parses the file and returns an array of hashed records.

sub _parse_file {
    my($self, $format) = @_;
    my($result) = [];

    my($file_name) = $self->{$_PACKAGE}->{directory}.'/'.$format->{file_name};
    open(IN, '< '.$file_name) or die("can't open file $file_name");
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
    close(IN) or die("couldn't close $file_name");

    # check for exception during read
    die($@) unless ($@ =~ /^end of input/) && ! $reading;

    if ($_TRACE) {
	foreach (@$result) {
	    _trace(Data::Dumper->Dumper($_));
	}
    }

    return $result;
}

# _import_transations(Transaction transaction, int source_id, date dttm, int transaction_type, hash_ref attributes)
#
# Creates the transaction and entries for all the data which occurs
# on the specified date within the specified transaction set index.

sub _import_transactions {
    my($self, $transaction, $source_id, $dttm, $transaction_type, $attributes) = @_;
    my($set_index) = $_TYPE_MAP->{$transaction_type}->[2];

    my($fields) = $self->{$_PACKAGE};

    my($member_trans) = $fields->{member_trans};
    my($instrument_trans) = $fields->{instrument_trans};
    my($cash_trans) = $fields->{cash_trans};

    my($entry) = Bivio::Biz::PropertyModel::Entry->new(
	    $transaction->get_request());
    my($member_entry) = Bivio::Biz::PropertyModel::MemberEntry->new(
	    $transaction->get_request());
    my($instrument_entry) = Bivio::Biz::PropertyModel::InstrumentEntry->new(
	    $transaction->get_request());
    my($account_entry) = Bivio::Biz::PropertyModel::AccountEntry->new(
	    $transaction->get_request());
    my($set) = $_TRANSACTION_ID_SET->[$set_index];
    my($handled) = 0;

    my($trans);
    foreach $trans (@$member_trans) {
	next if (! defined($trans));

	if ($trans->{member_id} == $source_id
		&& $trans->{dttm} == $dttm
		&& ($trans->{transaction_type} == $transaction_type
			or _contains($set, $trans->{transaction_type}))) {

	    $entry->create({
		transaction_id => $transaction->get('transaction_id'),
		class => Bivio::Type::EntryClass->MEMBER->as_int(),
		entry_type => $_TYPE_MAP->{
		    $trans->{transaction_type}}->[0]->as_int(),
		tax_category => $_TYPE_MAP->{
		    $trans->{transaction_type}}->[1]->as_int(),
		amount => $trans->{amount},
		remark => $trans->{remark},
	    });

	    $member_entry->create({
		entry_id => $entry->get('entry_id'),
		user_id => $attributes->{member_id_map}->{$trans->{member_id}},
		units => $trans->{'units'},
	    });

	    # set the transaction to undef in place
	    $trans = undef;
	    $handled = 1;
	}
    }

    foreach $trans (@$instrument_trans) {
	next if (! defined($trans));

	if ($trans->{instrument_id} == $source_id
		&& $trans->{dttm} == $dttm
		&& ($trans->{transaction_type} == $transaction_type
			or _contains($set, $trans->{transaction_type}))) {

	    $entry->create({
		transaction_id => $transaction->get('transaction_id'),
		class => Bivio::Type::EntryClass->INSTRUMENT->as_int(),
		entry_type => $_TYPE_MAP->{
		    $trans->{transaction_type}}->[0]->as_int(),
		tax_category => $_TYPE_MAP->{
		    $trans->{transaction_type}}->[1]->as_int(),
		amount => $trans->{amount},
		remark => $trans->{remark},
	    });

	    $instrument_entry->create({
		entry_id => $entry->get('entry_id'),
		instrument_id => $attributes->{instrument_id_map}->{
		    $trans->{instrument_id}},
		shares => $trans->{shares},
		block => $trans->{block},
	    });

	    # set the transaction to undef in place
	    $trans = undef;
	    $handled = 1;
	}
    }

    foreach $trans (@$cash_trans) {
	next if (! defined($trans));

	if ($trans->{source_id} == $source_id
		&& $trans->{dttm} == $dttm
		&& ($trans->{transaction_type} == $transaction_type
			or _contains($set, $trans->{transaction_type}))) {

	    my($trans_info) = $_TYPE_MAP->{$trans->{transaction_type}};
	    my($source_sign, $source) = $trans_info->[3] =~ /^(.)(.*)$/;
	    my($target_sign, $target) = $trans_info->[4] =~ /^(.)(.*)$/;

	    $source = _lookup_account($trans, $source) if (defined($source));
	    $target = _lookup_account($trans, $target) if (defined($target));

	    if (defined($source)) {
		$entry->create({
		    transaction_id => $transaction->get('transaction_id'),
		    class => Bivio::Type::EntryClass->ACCOUNT->as_int(),
		    entry_type => $trans_info->[0]->as_int(),
		    tax_category => $trans_info->[1]->as_int(),
		    amount => $trans->{amount},
		    remark => $trans->{remark},
		});

		die("invalid account: $source") if (! defined($attributes->{accounts}->{$source}));
		$account_entry->create({
		    entry_id => $entry->get('entry_id'),
		    account_id => $attributes->{accounts}->{$source}
		});
		$handled = 1;
	    }
	    if (defined($target)) {
		$entry->create({
		    transaction_id => $transaction->get('transaction_id'),
		    class => Bivio::Type::EntryClass->ACCOUNT->as_int(),
		    entry_type => $trans_info->[0]->as_int(),
		    tax_category => $trans_info->[1]->as_int(),
		    amount => $trans->{amount},
		    remark => $trans->{remark},
		});

		die("invalid account: $target") if (! defined($attributes->{accounts}->{$target}));
		$account_entry->create({
		    entry_id => $entry->get('entry_id'),
		    account_id => $attributes->{accounts}->{$target}
		});
		$handled = 1;
	    }
	    # set the transaction to undef in place
	    $trans = undef;
	}
    }
    die("Transaction not handled: $transaction_type\n") unless $handled;

    return;
}

# _lookup_account(hash_ref trans, string name) : string
#
# Returns the name of the target account

sub _lookup_account {
    my($trans, $name) = @_;

    if ($name eq 'cash') {
	my($account) = $trans->{account_type};
	$name = 'bank' if $account == 0;
	$name = 'broker' if $account == 1;
	$name = 'suspense' if $account == 2;
	$name = 'petty_cash' if $account == 3;
    }
    return $name;
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

#    _trace("boolean $value") if $_TRACE;
    return $value;
}

# _read_types(file, length) : string
#
# Reads and returns the specified number of bytes.

sub _read_bytes {
    my($file, $length) = @_;

    my($bytes);
    read(*$file, $bytes, $length) or die('end of input');

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

#    _trace("date $value") if $_TRACE;
    return $value;
}

# _read_double(file) : string
#
# Reads and returns an 8 byte double.

sub _read_double {
    my($file) = @_;

    my($value) = unpack('d', _read_bytes($file, 8));

#    _trace("double $value") if $_TRACE;
    return $value;
}

# _read_in2(file) : int
#
# Reads and returns a two byte integer.

sub _read_int2 {
    my($file) = @_;

    my($value) = unpack('s', _read_bytes($file, 2));

#    _trace("int $value") if $_TRACE;
    return $value;
}

# _read_int4(file) : int
#
# Reads and returns a four byte integer.

sub _read_int4 {
    my($file) = @_;

    my($value) = unpack('i', _read_bytes($file, 4));

#    _trace("int4 $value") if $_TRACE;
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

#    _trace("string '$value'") if $_TRACE;
    return $value;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
