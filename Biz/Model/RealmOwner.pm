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

#=IMPORTS
use Bivio::Auth::RealmType;
use Bivio::Biz::Model::RealmInstrument;
use Bivio::SQL::Connection;
use Bivio::SQL::Constraint;
use Bivio::Type::Amount;
use Bivio::Type::Date;
use Bivio::Type::EntryClass;
use Bivio::Type::RealmName;
use Bivio::Type::Name;
use Bivio::Type::PrimaryId;
use Bivio::Type::Password;
use Bivio::Type::DateTime;

#=VARIABLES

=head1 METHODS

=cut

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

    my($key) = ref($self).'get_instruments_info';
    my($cache) = $self->get_request->unsafe_get($key);
    return $cache if $cache;

#TODO: make this a ListModel
    my($sth) = Bivio::SQL::Connection->execute(
	    'select realm_instrument_t.realm_instrument_id, instrument_t.name, instrument_t.ticker_symbol from realm_instrument_t, instrument_t where realm_instrument_t.instrument_id = instrument_t.instrument_id and realm_id=? order by instrument_t.name',
	    [$self->get('realm_id')]);

    my($result) = [];

    my($row);
    while ($row = $sth->fetchrow_arrayref) {
	my($id, $name, $symbol) = @$row;
	push(@$result, [$id, $name, $symbol]);
    }
    $self->get_request->put($key => $result);
    return $result;
}

=for html <a name="get_cost_per_share"></a>

=head2 static get_cost_per_share(string date) : hash_ref

Returns the average cost per share for all the RealmInstruments owned
by the realm. Returns realm_instrument_id => cost.

=cut

sub get_cost_per_share {
    my($self, $date) = @_;

#TODO: THIS SHOULD ALL BE DONE IN SQL!
#      very clumsy with cost basis of fractional shares
#      need to separate shares returned (ignored)
#      from the value of the returned shares (affects total_cost)
    my($sth) = Bivio::SQL::Connection->execute(
	    'select realm_instrument_entry_t.realm_instrument_id, entry_t.amount, realm_instrument_entry_t.count, entry_t.entry_type, entry_t.tax_basis, entry_t.tax_category from realm_transaction_t, entry_t, realm_instrument_entry_t where realm_transaction_t.realm_transaction_id = entry_t.realm_transaction_id and entry_t.entry_id = realm_instrument_entry_t.entry_id and realm_instrument_entry_t.realm_instrument_id in (select realm_instrument_id from realm_instrument_t where realm_id=?) and realm_transaction_t.date_time <= '
	    .Bivio::Type::Date->to_sql_value('?'),
	   [$self->get('realm_id'),
		   Bivio::Type::Date->to_sql_param($date)]);

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

=head2 static get_number_of_shares(string date) : hash_ref

Returns the number of shares of RealmInstruments owned by the realm on the
specified date. Returns a hash of realm_instrument_id => count.

=cut

sub get_number_of_shares {
    my($self, $date) = @_;

    my($key) = ref($self).'get_number_of_shares';
    my($cache) = $self->get_request->unsafe_get($key);
    return $cache if $cache;

    # note: doesn't include fractional shares paid in cash (not tax basis)

    my($sth) = Bivio::SQL::Connection->execute(
	    'select realm_instrument_entry_t.realm_instrument_id, sum(realm_instrument_entry_t.count) from realm_transaction_t, entry_t, realm_instrument_entry_t where realm_transaction_t.realm_transaction_id = entry_t.realm_transaction_id and entry_t.entry_id = realm_instrument_entry_t.entry_id and entry_t.tax_basis = 1 and realm_instrument_entry_t.realm_instrument_id in (select realm_instrument_id from realm_instrument_t where realm_id=?) and realm_transaction_t.date_time <= '
	    .Bivio::Type::Date->to_sql_value('?')
	    .' group by realm_instrument_entry_t.realm_instrument_id',
	   [$self->get('realm_id'), Bivio::Type::Date->to_sql_param($date)]);

    my($result) = {};
    my($row);
    while ($row = $sth->fetchrow_arrayref()) {
	my($id, $count) = @$row;
	$result->{$id} = $count;
    }
    $self->get_request->put($key => $result);
    return $result;
}

=for html <a name="get_share_price"></a>

=head2 static get_share_price_and_date(string date) : hash_ref

Returns a hash of realm_instrument_id => [value, date] for the all
the RealmInstruments on the specified date.

=cut

sub get_share_price_and_date {
    my($self, $search_date) = @_;

    my($key) = ref($self).'get_share_price_and_date';
    my($cache) = $self->get_request->unsafe_get($key);
    return $cache if $cache;

    my($result) = {};

    # search last 8 days
    my($j, undef) = $search_date =~ /^(.*)\s(.*)$/;
    my(@dates) = ();
    for (1..8) {
	push(@dates, Bivio::Type::Date->to_sql_param($j--.' '
	       .Bivio::Type::DateTime::DEFAULT_TIME()));
    }
    my($dp) = Bivio::Type::Date->to_sql_value('?').',';
    my($dates_param) = $dp x int(@dates);
    chop($dates_param);

    # valuation algorithm:
    #   if not in MGFS use local (realm_instrument_valuation_t).
    #   if date < club-switch-over-date use local (TODO)

    my($id, $value, $date);
    my($sth) = Bivio::SQL::Connection->execute(
	    'select realm_instrument_t.realm_instrument_id, mgfs_daily_quote_t.close, '
	    .Bivio::Type::Date->from_sql_value(
		    'mgfs_daily_quote_t.date_time')
	    .' from realm_instrument_t, mgfs_instrument_t, mgfs_daily_quote_t where realm_instrument_t.realm_instrument_id in (select realm_instrument_t.realm_instrument_id from realm_instrument_t where realm_instrument_t.realm_id=?) and realm_instrument_t.instrument_id=mgfs_instrument_t.instrument_id and mgfs_instrument_t.mg_id=mgfs_daily_quote_t.mg_id and mgfs_daily_quote_t.date_time in ('
	    .$dates_param
	    .') order by mgfs_daily_quote_t.date_time desc',
	    [$self->get('realm_id'), @dates]);

    my($row);
    while ($row = $sth->fetchrow_arrayref()) {
	($id, $value, $date) = @$row;
	$date = Bivio::Type::Date->from_sql_column($date);

	unless (exists($result->{$id})) {
	    $result->{$id} = [$value, $date];
	}
    }

    # look for local valuations for non MGFS instruments
    # check for valuation within roughly 6 months (good enough?)
    my($six_months_ago) = Bivio::Type::Date->to_sql_param(($j - 180).' '
	       .Bivio::Type::DateTime::DEFAULT_TIME());

    $sth = Bivio::SQL::Connection->execute(
	    'select realm_instrument_valuation_t.realm_instrument_id, realm_instrument_valuation_t.price_per_share, '
	    .Bivio::Type::Date->from_sql_value(
			'realm_instrument_valuation_t.date_time')
	    .' from realm_instrument_valuation_t where realm_instrument_valuation_t.realm_id=? and realm_instrument_valuation_t.date_time between '
	    .Bivio::Type::Date->to_sql_value('?').' and '
	    .Bivio::Type::Date->to_sql_value('?')
	    .' order by realm_instrument_valuation_t.date_time desc',
	    [$self->get('realm_id'), $six_months_ago,
		    Bivio::Type::Date->to_sql_param($search_date)]);

    while ($row = $sth->fetchrow_arrayref()) {
	($id, $value, $date) = @$row;
	$date = Bivio::Type::Date->from_sql_column($date);

#TODO: this should override for club cross-over date to preserve easyware data
	unless (exists($result->{$id})) {
	    $result->{$id} = [$value, $date];
	}
    }

    $self->get_request->put($key => $result);
    return $result;
}

=for html <a name="get_unit_value"></a>

=head2 get_unit_value(Bivio::Type::Date date) : string

Returns the unit value for the realm on the specified date.

=cut

sub get_unit_value {
    my($self, $date) = @_;

    my($units) = $self->get_units($date);
    return $units == 0 ? 0
	    : Bivio::Type::Amount->div($self->get_value($date), $units);
}

=for html <a name="get_units"></a>

=head2 get_units(Bivio::Type::Date date) : string

Returns the total number of units purchased in the realm up to the specified
date.

=cut

sub get_units {
    my($self, $date) = @_;

    my($key) = ref($self).'get_units';
    my($cache) = $self->get_request->unsafe_get($key);
    return $cache if $cache;

    my($sth) = Bivio::SQL::Connection->execute(
	    'select sum(member_entry_t.units) from realm_transaction_t, entry_t, member_entry_t where realm_transaction_t.realm_transaction_id = entry_t.realm_transaction_id and entry_t.entry_id = member_entry_t.entry_id and realm_transaction_t.realm_id=? and realm_transaction_t.date_time <= '
	    .Bivio::Type::Date->to_sql_value('?'),
	    [$self->get('realm_id'),
		    Bivio::Type::Date->to_sql_param($date)]);

    my($units) = $sth->fetchrow_arrayref()->[0] || '0';
    $self->get_request->put($key => $units);
    return $units;
}

=for html <a name="get_value"></a>

=head2 get_value(Bivio::Type::Date date) : string

Returns the realm's value on the specified date.

=cut

sub get_value {
    my($self, $date) = @_;

    my($key) = ref($self).'get_value';
    my($cache) = $self->get_request->unsafe_get($key);
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
    $self->get_request->put($key => $value);
    return $value;
}

=for html <a name="get_tax_basis"></a>

=head2 get_tax_basis(EntryClass class, Bivio::Type::Date date) : string

Returns the total tax basis of the specified entry class up to the specified
date.

=cut

sub get_tax_basis {
    my($self, $class, $date) = @_;

    my($sth) = Bivio::SQL::Connection->execute(
	    'select sum(entry_t.amount) from realm_transaction_t, entry_t where realm_transaction_t.realm_transaction_id = entry_t.realm_transaction_id and entry_t.tax_basis = 1 and realm_transaction_t.realm_id=? and entry_t.class=? and realm_transaction_t.date_time <= '
	    .Bivio::Type::Date->to_sql_value('?'),
	   [$self->get('realm_id'), $class->as_int(),
		   Bivio::Type::Date->to_sql_param($date)]);
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
	    display_name => ['Bivio::Type::Name',
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

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
