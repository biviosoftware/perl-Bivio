# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
# Generated by ../generate.PL on Wed Aug 18  7:57:50 1999
# from tables.sql,v 1.13 1999/08/13 17:06:21 moeller Exp 
package Bivio::Biz::Model::RealmOwner;
use strict;
$Bivio::Biz::Model::RealmOwner::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::RealmOwner - interface to realm_owner_t SQL table

=head1 SYNOPSIS

    use Bivio::Biz::Model::RealmOwner;
    Bivio::Biz::Model::RealmOwner->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::RealmOwner::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::RealmOwner> is the create, read, update,
and delete interface to the C<realm_owner_t> table.

=cut


=head1 CONSTANTS

=cut

=for html <a name="DEFAULT_UNIT_VALUE"></a>

=head2 DEFAULT_UNIT_VALUE : string

The unit value used when a valid unit value can't be caluculated.
Used when a club if first started, but no securities have been purchased.

=cut

sub DEFAULT_UNIT_VALUE {
    return '10.0';
}

#=IMPORTS
use Bivio::Auth::RealmType;
use Bivio::Biz::Model::MemberEntry;
use Bivio::Biz::Model::MemberEntryList;
use Bivio::Biz::Model::RealmInstrument;
use Bivio::IO::Trace;
use Bivio::SQL::Connection;
use Bivio::SQL::Constraint;
use Bivio::SQL::ListQuery;
use Bivio::Type::Amount;
use Bivio::Type::DateTime;
use Bivio::Type::EntryClass;
use Bivio::Type::Integer;
use Bivio::Type::RealmName;
use Bivio::Type::Name;
use Bivio::Type::Number;
use Bivio::Type::PrimaryId;
use Bivio::Type::Password;
use Bivio::Type::DateTime;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_SQL_DATE_VALUE) = Bivio::Type::DateTime->to_sql_value('?');

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Agent::Request req) : Bivio::Biz::Model::AccountSummaryList

Creates a RealmOwner.

=cut

sub new {
    my($self) = &Bivio::Biz::PropertyModel::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="audit_units"></a>

=head2 audit_units(string date)

Recalculates and adjusts member entries which affect units after the
specified date.

=cut

sub audit_units {
    my($self, $date) = @_;
    my($req) = $self->get_request;
    my($member_entry) = Bivio::Biz::Model::MemberEntry->new($req);
    my($entries) = Bivio::Biz::Model::MemberEntryList->new($req);
#TODO: really want all entries >= date, for now just get all of them
    $entries->load(
	    Bivio::SQL::ListQuery->new({
		count => Bivio::Type::Integer->get_max,
		auth_id => $req->get('auth_id'),
#TODO: this doesn't look right
	    }, $entries->internal_get_sql_support()));

    while ($entries->next_row) {
	my($val_date) = $entries->get('MemberEntry.valuation_date');
	next unless defined($val_date);

	my($type) = $entries->get('Entry.entry_type');
	next unless ($type == Bivio::Type::EntryType::MEMBER_PAYMENT()
#TODO: add handling for other types as they become known
#		|| $type
#		== Bivio::Type::EntryType::MEMBER_WITHDRAWAL_PARTIAL_CASH()
#		|| $type
#		== Bivio::Type::EntryType::MEMBER_WITHDRAWAL_FULL_CASH);
	       );

	if (Bivio::Type::Date->compare($val_date, $date) >= 0) {

	    my($id, $amount, $units, $tran_date) = $entries->get(
		    'Entry.entry_id', 'Entry.amount', 'MemberEntry.units',
		    'RealmTransaction.date_time');

	    # don't include member payments on val_date
	    my($unit_value) = _get_unit_value($self, $val_date, 0);
	    my($real_units) = Bivio::Type::Amount->div($amount, $unit_value);

	    #_trace("\n$units\t$real_units");
	    # easyware data correct to 6 decimal places
	    if (Bivio::Type::Number->compare($units, $real_units, 6) != 0) {
		my($display_date) = Bivio::Type::Date->to_literal($val_date);
		_trace("\n$display_date units incorrect:\n\t"
			."$units != $real_units");
		$member_entry->load(entry_id => $id);
		$member_entry->update({units => $real_units});
	    }
	}
    }
    return;
}

=for html <a name="create"></a>

=head2 create(hash_ref new_values)

Sets I<creation_date_time>, I<password> (to invalid),
and I<display_name> if not set, then calls SUPER.

=cut

sub create {
    my($self, $values) = @_;
    $values->{display_name} = $values->{name}
	    unless defined($values->{display_name});
    $values->{creation_date_time} = Bivio::Type::DateTime->now()
	    unless defined($values->{creation_date_time});
    $values->{password} = 'xx'
	    unless defined($values->{password});
    return $self->SUPER::create($values);
}

=for html <a name="format_email"></a>

=head2 format_email() : string

Returns fully-qualified email address for this realm.

=cut

sub format_email {
    my($self) = @_;
#TODO: Need to modify Request to handle this case.
    return $self->get('name').'@'.$self->get_request->get('mail_host')
}

=for html <a name="format_http"></a>

=head2 format_http() : string

Returns the absolute URL (with http) to access (the root of) this realm.

HACK!

=cut

sub format_http {
    my($self) = @_;
#TODO: This is a total hack.   Need to know the "root" task
    return 'https://'.$self->get_request->get('http_host')
	    .'/'.$self->get('name');
}

=for html <a name="format_uri"></a>

=head2 format_uri() : string

Returns the URI to access (the root of) this realm.

HACK!

=cut

sub format_uri {
    my($self) = @_;
#TODO: This is a total hack.   Need to know the "root" task
    return '/'.$self->get('name');
}

=for html <a name="get_instruments_info"></a>

=head2 get_instruments_info() : array_ref

Returns an array of realm instrument records (id, name, symbol).

=cut

sub get_instruments_info {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($cache) = $fields->{get_instruments_info};
    return $cache if $cache;

#TODO: make this a ListModel
    my($query) = <<'EOF';
	SELECT realm_instrument_t.realm_instrument_id,
	    instrument_t.name,
	    instrument_t.ticker_symbol
	FROM realm_instrument_t, instrument_t
        WHERE realm_instrument_t.instrument_id = instrument_t.instrument_id
	AND realm_id=?
	ORDER BY instrument_t.name
EOF
    my($sth) = Bivio::SQL::Connection->execute($query,
	    [$self->get('realm_id')]);

    my($result) = [];

    my($row);
    while ($row = $sth->fetchrow_arrayref) {
	my($id, $name, $symbol) = @$row;
	push(@$result, [$id, $name, $symbol]);
    }
    $fields->{get_instruments_info} = $result;
    return $result;
}

=for html <a name="get_cost_per_share"></a>

=head2 get_cost_per_share(string date) : hash_ref

Returns the average cost per share for all the RealmInstruments owned
by the realm. Returns realm_instrument_id => cost.

=cut

sub get_cost_per_share {
    my($self, $date) = @_;

#TODO: THIS SHOULD ALL BE DONE IN SQL!
#      very clumsy with cost basis of fractional shares
#      need to separate shares returned (ignored)
#      from the value of the returned shares (affects total_cost)
    my($query) = <<"EOF";
	SELECT realm_instrument_entry_t.realm_instrument_id,
	    entry_t.amount,
	    realm_instrument_entry_t.count,
	    entry_t.entry_type,
	    entry_t.tax_basis,
	    entry_t.tax_category
	FROM realm_transaction_t, entry_t, realm_instrument_entry_t
	WHERE realm_transaction_t.realm_transaction_id
	    = entry_t.realm_transaction_id
	AND entry_t.entry_id = realm_instrument_entry_t.entry_id
	AND realm_instrument_entry_t.realm_id = ?
	AND realm_transaction_t.date_time <= $_SQL_DATE_VALUE
EOF
    my($sth) = Bivio::SQL::Connection->execute($query,
	   [$self->get('realm_id'),
		   Bivio::Type::DateTime->to_sql_param($date)]);

    my($result) = {};
    my($row);
    while ($row = $sth->fetchrow_arrayref()) {
	my($id, $cost, $count, $type, $basis, $tax) = @$row;
	my($pair) = $result->{$id};
	unless ($pair) {
	    $pair = $result->{$id} = [0, 0],
	}

	if ($basis) {
	    $pair->[0] = Bivio::Type::Amount->add($pair->[0], $cost);
	}
	elsif ($tax == Bivio::Type::TaxCategory->NOT_TAXABLE->as_int()
#TODO: ugh - consider consolidating SHARES_AS_CASH types
		&& ($type == Bivio::Type::EntryType
			->INSTRUMENT_SPLIT_SHARES_AS_CASH->as_int()
		    || $type == Bivio::Type::EntryType
			->INSTRUMENT_SPINOFF_SHARES_AS_CASH->as_int()
		    || $type == Bivio::Type::EntryType
			->INSTRUMENT_MERGER_SHARES_AS_CASH->as_int())) {
	    $pair->[0] = Bivio::Type::Amount->add($pair->[0], $cost);
	}
	if ($basis) {
	    $pair->[1] = Bivio::Type::Amount->add($pair->[1], $count);
	}
    }
    foreach my $id (keys(%$result)) {
	my($total_cost, $total_count) = @{$result->{$id}};
	$result->{$id} = $total_count == 0 ? 0
	    : Bivio::Type::Amount->div($total_cost, $total_count);
    }
    return $result;
}

=for html <a name="get_number_of_shares"></a>

=head2 get_number_of_shares(string date) : hash_ref

Returns the number of shares of RealmInstruments owned by the realm on the
specified date. Returns a hash of realm_instrument_id => count.

=cut

sub get_number_of_shares {
    my($self, $date) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($cache) = $fields->{'get_number_of_shares'.$date};
    return $cache if $cache;

    # note: doesn't include fractional shares paid in cash (not tax basis)
    my($query) = <<"EOF";
	SELECT realm_instrument_entry_t.realm_instrument_id,
	    sum(realm_instrument_entry_t.count)
	FROM realm_transaction_t,
	    entry_t,
	    realm_instrument_entry_t
	WHERE
	    realm_instrument_entry_t.realm_id = ?
	    AND realm_transaction_t.realm_transaction_id
		    = entry_t.realm_transaction_id
	    AND entry_t.entry_id = realm_instrument_entry_t.entry_id
	    AND entry_t.tax_basis = 1
	    AND realm_transaction_t.date_time <= $_SQL_DATE_VALUE
	GROUP BY realm_instrument_entry_t.realm_instrument_id
EOF
    my($sth) = Bivio::SQL::Connection->execute($query,
	   [$self->get('realm_id'),
	       Bivio::Type::DateTime->to_sql_param($date)]);

    my($result) = {};
    my($row);
    while ($row = $sth->fetchrow_arrayref()) {
	my($id, $count) = @$row;
	$result->{$id} = $count;
    }
    $fields->{'get_number_of_shares'.$date} = $result;
    return $result;
}

=for html <a name="get_share_price_and_date"></a>

=head2 get_share_price_and_date(string date) : hash_ref

Returns a hash of realm_instrument_id => [value, date] for the all
the RealmInstruments on the specified date.

=cut

sub get_share_price_and_date {
    my($self, $search_date) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($cache) = $fields->{'get_share_price_and_date'.$search_date};
    return $cache if $cache;

    my($result) = {};

    # search last 8 days
    my($j, undef) = $search_date =~ /^(.*)\s(.*)$/;
    my($dates) = '';
    for (1..8) {
	$dates .= Bivio::Type::DateTime->to_sql_value(
		"'".Bivio::Type::DateTime->to_sql_param($j--.' '
			.Bivio::Type::DateTime::DEFAULT_TIME())."'").',';
    }
    chop($dates);

    # valuation algorithm:
    #   if realm_instrument_valuation_t exists for the date, use it
    #   if not in MGFS use local (realm_instrument_valuation_t).
    #   otherwise get most recent value from realm_instrument_valuation_t

    my($id, $value, $date);

    # look on exactly that date, allows a local override
    my($sth) = Bivio::SQL::Connection->execute("
            SELECT realm_instrument_id, price_per_share
            FROM realm_instrument_valuation_t
            WHERE realm_id=?
            AND date_time=$_SQL_DATE_VALUE",
	    [$self->get('realm_id'), $search_date]);
    my($row);
    while ($row = $sth->fetchrow_arrayref) {
	($id, $value) = @$row;
	$result->{$id} = [$value, $search_date];
    }

    my($d) = Bivio::Type::DateTime->from_sql_value(
	    'mgfs_daily_quote_t.date_time');
    $sth = Bivio::SQL::Connection->execute(
	    <<"EOF", [$self->get('realm_id')]);
	    SELECT realm_instrument_t.realm_instrument_id,
	    	mgfs_daily_quote_t.close, $d
	    FROM realm_instrument_t, mgfs_instrument_t, mgfs_daily_quote_t
	    WHERE realm_instrument_t.realm_id =?
	    AND realm_instrument_t.instrument_id
            	=mgfs_instrument_t.instrument_id
            AND mgfs_instrument_t.mg_id=mgfs_daily_quote_t.mg_id
            AND mgfs_daily_quote_t.date_time in ($dates)
            ORDER BY mgfs_daily_quote_t.date_time DESC
EOF

    while ($row = $sth->fetchrow_arrayref) {
	($id, $value, $date) = @$row;
	$date = Bivio::Type::DateTime->from_sql_column($date);

	unless (exists($result->{$id})) {
	    $result->{$id} = [$value, $date];
	}
    }

    # make sure that valuations exists for every realm instrument
    # if not, then go to the realm_instrument_valuation_t which
    # is guarenteed to have at least buy/sell valuations

    $sth = Bivio::SQL::Connection->execute('
            SELECT realm_instrument_t.realm_instrument_id
            FROM realm_instrument_t
            WHERE realm_instrument_t.realm_id=?',
	    [$self->get('realm_id')]);

    while ($row = $sth->fetchrow_arrayref) {
	($id) = @$row;

	next if exists($result->{$id});

	$d = Bivio::Type::DateTime->from_sql_value(
		'realm_instrument_valuation_t.date_time');
	$d = <<"EOF";
	    SELECT realm_instrument_valuation_t.price_per_share,
	    $d
	    FROM realm_instrument_valuation_t
	    WHERE realm_instrument_valuation_t.realm_id=?
            AND realm_instrument_valuation_t.realm_instrument_id=?
            AND realm_instrument_valuation_t.date_time <= $_SQL_DATE_VALUE
	    ORDER BY realm_instrument_valuation_t.date_time DESC
EOF
	my($sth2) = Bivio::SQL::Connection->execute($d,
		[$self->get('realm_id'), $id,
			Bivio::Type::DateTime->to_sql_param($search_date)]);

	my($row2);
	if ($row2 = $sth2->fetchrow_arrayref()) {
	    ($value, $date) = @$row2;
	    $date = Bivio::Type::DateTime->from_sql_column($date);
	    $result->{$id} = [$value, $date];
	}
    }

    $fields->{'get_share_price_and_date'.$search_date} = $result;
    return $result;
}

=for html <a name="get_unit_value"></a>

=head2 get_unit_value(Bivio::Type::Date date) : string

Returns the unit value for the realm on the specified date.

=cut

sub get_unit_value {
    my($self, $date) = @_;

    return _get_unit_value($self, $date, 1);
}

=for html <a name="get_units"></a>

=head2 get_units(Bivio::Type::DateTime date) : string

Returns the total number of units purchased in the realm up to the specified
date.

=cut

sub get_units {
    my($self, $date) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($cache) = $fields->{'get_units'.$date};
    return $cache if $cache;

    my($query) = <<"EOF";
	SELECT SUM(member_entry_t.units)
	FROM realm_transaction_t, entry_t, member_entry_t
	WHERE realm_transaction_t.realm_transaction_id
	    =entry_t.realm_transaction_id
	AND entry_t.entry_id = member_entry_t.entry_id
 	AND realm_transaction_t.realm_id=?
	AND realm_transaction_t.date_time <= $_SQL_DATE_VALUE
EOF
    my($sth) = Bivio::SQL::Connection->execute($query,
	    [$self->get('realm_id'),
		    Bivio::Type::DateTime->to_sql_param($date)]);

    my($units) = $sth->fetchrow_arrayref()->[0] || '0';
    $fields->{'get_units'.$date} = $units;
    return $units;
}

=for html <a name="get_value"></a>

=head2 get_value(Bivio::Type::DateTime date) : string

Returns the realm's value on the specified date.

=cut

sub get_value {
    my($self, $date) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($cache) = $fields->{'get_value'.$date};
    return $cache if $cache;

    my($value) = $self->get_tax_basis(Bivio::Type::EntryClass->CASH, $date);

    my($instruments) = $self->get_instruments_info();
    my($price_dates) = $self->get_share_price_and_date($date);
    my($shares) = $self->get_number_of_shares($date);

    foreach my $inst (@$instruments) {
	my($id) = $inst->[0];
	my($price) = $price_dates->{$id}->[0] || 0;
	$value = Bivio::Type::Amount->add($value,
		Bivio::Type::Amount->mul($shares->{$id} || 0, $price));
    }
    $fields->{'get_value'.$date} = $value;
    return $value;
}

=for html <a name="get_tax_basis"></a>

=head2 get_tax_basis(EntryClass class, Bivio::Type::DateTime date) : string

Returns the total tax basis of the specified entry class up to the specified
date.

=cut

sub get_tax_basis {
    my($self, $class, $date) = @_;

    my($query) = <<"EOF";
	SELECT sum(entry_t.amount)
	FROM realm_transaction_t, entry_t
	WHERE realm_transaction_t.realm_transaction_id
		= entry_t.realm_transaction_id
	AND entry_t.tax_basis = 1
	AND realm_transaction_t.realm_id=?
	AND entry_t.class=?
	AND realm_transaction_t.date_time <= $_SQL_DATE_VALUE
EOF
    my($sth) = Bivio::SQL::Connection->execute($query,
	   [$self->get('realm_id'), $class->as_int(),
		   Bivio::Type::DateTime->to_sql_param($date)]);
    return $sth->fetchrow_arrayref()->[0] || '0.00';
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'realm_owner_t',
	columns => {
            realm_id => ['Bivio::Type::PrimaryId',
    		Bivio::SQL::Constraint::PRIMARY_KEY()],
            name => ['Bivio::Type::RealmName',
    		Bivio::SQL::Constraint::NOT_NULL_UNIQUE()],
            password => ['Bivio::Type::Password',
    		Bivio::SQL::Constraint::NOT_NULL()],
            realm_type => ['Bivio::Auth::RealmType',
    		Bivio::SQL::Constraint::NOT_NULL()],
	    display_name => ['Bivio::Type::Line',
    		Bivio::SQL::Constraint::NOT_NULL()],
	    creation_date_time => ['Bivio::Type::DateTime',
		Bivio::SQL::Constraint::NOT_NULL()],
        },
	auth_id => 'realm_id',
	other => [
	    [qw(realm_id Club.club_id User.user_id)],
	],
    };
}

#=PRIVATE METHODS

# _get_unit_value(string date, boolean include_todays_member_entries) : string
#
# Returns the unit value for the specified date.
# If include_todays_member_entries is false, then the result won't include
# member entries on the specified date.
#
sub _get_unit_value {
    my($self, $date, $include_todays_member_entries) = @_;

    my($units) = $self->get_units($date);
    my($value) = $self->get_value($date);

    unless ($include_todays_member_entries) {
	# get the member unit and amount for the day
	# then subtract it from the previous totals
	my($query) = <<"EOF";
  	    SELECT SUM(member_entry_t.units),
                SUM(entry_t.amount)
	    FROM realm_transaction_t, entry_t, member_entry_t
	    WHERE realm_transaction_t.realm_transaction_id
	        =entry_t.realm_transaction_id
	    AND entry_t.entry_id = member_entry_t.entry_id
 	    AND realm_transaction_t.realm_id=?
	    AND realm_transaction_t.date_time = $_SQL_DATE_VALUE
EOF

	my($sth) = Bivio::SQL::Connection->execute($query,
		[$self->get('realm_id'),
			Bivio::Type::DateTime->to_sql_param($date)]);
	# returns at most one row
	my($row);
	while ($row = $sth->fetchrow_arrayref) {
	    my($mem_units, $mem_value) = @$row;
	    $units = Bivio::Type::Amount->sub($units, $mem_units)
		    if ($mem_units);
	    $value = Bivio::Type::Amount->sub($value, $mem_value)
		    if ($mem_value);
	}
    }
    my($result) =  $units == 0 ? 0 : Bivio::Type::Amount->div($value, $units);

    my($display_date) = Bivio::Type::Date->to_literal($date);
    _trace("\nunit_value $display_date units: ".$units."\tvalue: ".$value);

    # a value of 0 will only occur if no securities are owned
    return $result || DEFAULT_UNIT_VALUE();
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
