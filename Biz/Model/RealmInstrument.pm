# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::RealmInstrument;
use strict;
$Bivio::Biz::Model::RealmInstrument::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::RealmInstrument::VERSION;

=head1 NAME

Bivio::Biz::Model::RealmInstrument - interface to realm_instrument_t SQL table

=head1 SYNOPSIS

    use Bivio::Biz::Model::RealmInstrument;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::RealmInstrument::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::RealmInstrument> is the create, read, update,
and delete interface to the C<realm_instrument_t> table.

=cut

#=IMPORTS
use Bivio::Biz::Model::Instrument;
use Bivio::Biz::Model::RealmAccount;
use Bivio::SQL::Connection;
use Bivio::Type::EntryClass;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="cascade_delete"></a>

=head2 cascade_delete()

Deletes this realm instrument and any valuations associated with it.
This method will die if the instrument has any accounting transactions.

=cut

sub cascade_delete {
    my($self) = @_;

    # delete any valuations
    Bivio::SQL::Connection->execute('
            DELETE FROM realm_instrument_valuation_t
            WHERE realm_id=?
            AND realm_instrument_id=?',
	    [$self->get('realm_id', 'realm_instrument_id')]);

    $self->delete();
    return;
}

=for html <a name="create"></a>

=head2 create(hash_ref new_values)

Sets I<average_cost_method> and I<drp_plan> if not set, then calls SUPER.

=cut

sub create {
    my($self, $values) = @_;
    $values->{average_cost_method} = 0
	    unless exists($values->{average_cost_method});
    $values->{drp_plan} = 0 unless exists($values->{drp_plan});
    _assert_values($self, $values);
    _fixup_symbols($values);
    return $self->SUPER::create($values);
}

=for html <a name="format_name_ticker_symbol"></a>

=head2 format_name_ticker_symbol() : string

Formats the name and ticker using
L<Bivio::Biz::Model::Instrument::concat_name_ticker_symbol|Bivio::Biz::Model::Instrument/"concat_name_ticker_symbol">.

=cut

sub format_name_ticker_symbol {
    my($self) = @_;
    return Bivio::Biz::Model::Instrument->concat_name_ticker_symbol(
	    $self->get_name, $self->get_ticker_symbol);
}

=for html <a name="get_count"></a>

=head2 static get_count(Bivio::Agent::Request req) : string

Returns the number of realm instruments for the current club.

=cut

sub get_count {
    my($proto, $req) = @_;
    return _get_count($req, 'realm_id', $req->get('auth_id'));
}

=for html <a name="get_fed_tax_free"></a>

=head2 get_fed_tax_free() : string

Returns the local fed_tax_free, or from the instrument.

=cut

sub get_fed_tax_free {
    my($self) = @_;
    return _get_field_value($self, 'fed_tax_free');
}

=for html <a name="get_name"></a>

=head2 get_name() : string

Returns the local name, or the instrument name depending on whether this
is a realm-local instrument.

=cut

sub get_name {
    my($self) = @_;
    return _get_field_value($self, 'name');
}

=for html <a name="get_shares_owned"></a>

=head2 get_shares_owned(string date) : string

=head2 get_shares_owned(string date, boolean refresh) : string

Returns the number of shares owned on the specified date.
If refresh is specified and is true, then the cached value won't
be used and the query will be made again.

=cut

sub get_shares_owned {
    my($self, $date, $refresh) = @_;
    my($realm) = $self->get_request->get('auth_realm')->get('owner');
    $realm->clear_instrument_cache if $refresh;
    return $realm->get_number_of_shares($date)
		->{$self->get('realm_instrument_id')} || 0;
}

=for html <a name="get_ticker_symbol"></a>

=head2 get_ticker_symbol() : string

Returns the local ticker_symbol or the instrument ticker_symbol
depending on whether this is a realm-local instrument.

=cut

sub get_ticker_symbol {
    my($self) = @_;
    return _get_field_value($self, 'ticker_symbol');
}

=for html <a name="has_transactions"></a>

=head2 has_transactions() : boolean

Returns 1 if the instrument has accounting transactions within the realm.

=cut

sub has_transactions {
    my($self) = @_;

    my($sth) = Bivio::SQL::Connection->execute('
            SELECT COUNT(*)
            FROM realm_instrument_entry_t
            WHERE realm_id=?
            AND realm_instrument_id=?',
	    [$self->get('realm_id', 'realm_instrument_id')]);
    my($count) = 0;
    while (my $row = $sth->fetchrow_arrayref) {
	$count = $row->[0] || 0;
    }
    return $count ? 1 : 0;
}

=for html <a name="is_local"></a>

=head2 is_local() : boolean

Returns true if the instrument is club-local, false otherwise.

=cut

sub is_local {
    my($self) = @_;
    return defined($self->get('instrument_id')) ? 0 : 1;
}

=for html <a name="is_using_lots"></a>

=head2 is_using_lots() : boolean

Returns true if the instrument uses lots (not average cost).

=cut

sub is_using_lots {
    my($self) = @_;
    return ! $self->get('average_cost_method');
}

=for html <a name="set_instrument_id"></a>

=head2 set_instrument_id(string instrument_id)

Sets the instrument id and clears all local instrument fields for the
current model.

=cut

sub set_instrument_id {
    my($self, $instrument_id) = @_;
    die("missing instrument_id") unless defined($instrument_id);

    $self->update({
	instrument_id => $instrument_id,
	name => undef,
	ticker_symbol => undef,
	exchange_name => undef,
	instrument_type => undef,
	fed_tax_free => undef,
    });
    return;
}

=for html <a name="unsafe_find_or_create"></a>

=head2 unsafe_find_or_create(string ticker) : boolean

Attempts to find a realm instrument with the specified ticker. If
no realm instrument exists, then a new one is created.
On success, 1 is returned.
If no instrument exists for the ticker, then 0 is returned.

=cut

sub unsafe_find_or_create {
    my($self, $ticker) = @_;
    my($req) = $self->get_request;
    $ticker = uc($ticker);

    # guard against multiple realm instruments with same ticker
    return -1 if _get_count($req, 'ticker_symbol', $ticker) > 1;

    # check local instrument first
    if ($self->unsafe_load(ticker_symbol => $ticker)) {
	return 1;
    }

    # load the instrument from the ticker
    my($inst) = Bivio::Biz::Model::Instrument->new($req);
    unless ($inst->unsafe_load(ticker_symbol => $ticker)) {
	return 0;
    }
    my($inst_id) = $inst->get('instrument_id');

    # guard agains multiple realm instruments with same instrument_id
    return -1 if _get_count($req, 'instrument_id', $inst_id) > 1;

    # see if there is a realm instrument for it
    unless ($self->unsafe_load(instrument_id => $inst_id)) {
	# need to create it
	$self->create({
	    instrument_id => $inst->get('instrument_id'),
	    realm_id => $req->get('auth_id'),
	});
    }
    return 1;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'realm_instrument_t',
	columns => {
            realm_instrument_id => ['PrimaryId', 'PRIMARY_KEY'],
            instrument_id => ['PrimaryId', 'NOT_NULL'],
            realm_id => ['PrimaryId', 'NOT_NULL'],
            account_number => ['Name', 'NONE'],
            average_cost_method => ['Boolean', 'NOT_NULL'],
            drp_plan => ['Boolean', 'NOT_NULL'],
            remark => ['Text', 'NONE'],
            name => ['Line', 'NOT_NULL'],
            ticker_symbol => ['Name', 'NONE'],
            exchange_name => ['Name', 'NONE'],
            instrument_type => ['InstrumentType', 'NONE'],
            fed_tax_free => ['Boolean', 'NONE'],
	    country => ['Country', 'NONE'],
        },
	other => [
	    [qw(instrument_id Instrument.instrument_id)],
	],
	auth_id => 'realm_id',
    };
}

=for html <a name="unsafe_get_account"></a>

=head2 unsafe_get_account() : Bivio::Biz::Model::RealmAccount

Returns the account associated with this instrument. This is determined by
the most recent transaction's account. If there are no transactions, then
the club default account is used.

Returns undef if there are no transactions, and the default account is not
valid.

=cut

sub unsafe_get_account {
    my($self) = @_;
    my($req) = $self->get_request;
    my($account) = Bivio::Biz::Model::RealmAccount->new($req);

    # try to get the latest account used for this instrument
    my($account_id);
    my($sth) = Bivio::SQL::Connection->execute('
            SELECT DISTINCT realm_account_entry_t.realm_account_id
            FROM realm_transaction_t,
                entry_t ie,
                entry_t ae,
                realm_account_entry_t,
                realm_instrument_entry_t
            WHERE realm_transaction_t.realm_id=?
            AND realm_transaction_t.realm_transaction_id
                =ie.realm_transaction_id
            AND realm_transaction_t.realm_transaction_id
                =ae.realm_transaction_id
            AND ie.entry_id=realm_instrument_entry_t.entry_id
            AND realm_instrument_entry_t.realm_instrument_id=?
            AND ae.entry_id=realm_account_entry_t.entry_id
            AND realm_transaction_t.date_time=(
                SELECT max(realm_transaction_t.date_time)
                FROM realm_transaction_t, entry_t ie, entry_t ae,
                    realm_instrument_entry_t
                WHERE realm_transaction_t.realm_id=?
                AND realm_transaction_t.realm_transaction_id
                =ie.realm_transaction_id
                AND realm_transaction_t.realm_transaction_id
                =ae.realm_transaction_id
		AND ie.entry_id=realm_instrument_entry_t.entry_id
                AND realm_instrument_entry_t.realm_instrument_id=?
                AND ae.class=?
            )',
	    [$req->get('auth_id'), $self->get('realm_instrument_id'),
		    $req->get('auth_id'), $self->get('realm_instrument_id'),
		    Bivio::Type::EntryClass::CASH()->as_int]);

    while (my $row = $sth->fetchrow_arrayref) {
	$account_id = $row->[0];
    }

    if ($account_id) {
	$account->load(realm_account_id => $account_id);
    }
    elsif ($account->unsafe_load_default) {
	# use the default account
    }
    else {
	# no default account found
	return undef;
    }
    return $account;
}

=for html <a name="update"></a>

=head2 update(hash_ref new_values) : self

Updates the values.  Making sure all values exist.

=cut

sub update {
    my($self, $new_values) = @_;
    # Assert the combination of new and old are valid values
    _assert_values($self, {%{$self->internal_get()}, %{$new_values}});
    _fixup_symbols($new_values);
    return $self->SUPER::update($new_values)
}

#=PRIVATE METHODS

# _assert_values(self, hash_ref values)
#
# Asserts values are valid.
#
sub _assert_values {
    my($self, $values) = @_;
    if ($values->{instrument_id}) {
	# don't allow club-local fields if refers to an instrument
	foreach my $f (qw(fed_tax_free instrument_type name
              ticker_symbol exchange_name)) {
	    $self->throw_die('DIE', {
		message => 'field must not exist for non-local',
		entity => $f,
	    }) if defined($values->{$f});
	}
    }
    else {
	# require certain fields if local
	foreach my $f (qw(fed_tax_free instrument_type name)) {
	    $self->throw_die('DIE', {
		message => 'field must exist for local',
		entity => $f,
	    }) unless defined($values->{$f});
	}
    }
    return;
}

# _fixup_symbols(hash_ref values)
#
# Ensure the symbols are in upper case.
#
sub _fixup_symbols {
    my($values) = @_;
    foreach my $f (qw(ticker_symbol exchange_name)) {
	$values->{$f} = uc($values->{$f}) if defined($values->{$f});
    }
    return;
}

# _get_count(Bivio::Agent::Request req, string field, string value) : int
#
# Returns the number of RealmInstruments where the specified field
# has the specified value.
#
sub _get_count {
    my($req, $field, $value) = @_;
    my($sth) = Bivio::SQL::Connection->execute("
            SELECT COUNT(*)
            FROM realm_instrument_t
            WHERE $field=?
            AND realm_id=?",
	    [$value, $req->get('auth_id')]);
    my($count) = 0;
    while (my $row = $sth->fetchrow_arrayref) {
	$count = $row->[0];
    }
    return $count;
}

# _get_field_value(string field) : string
#
# Returns the specified field's value, retreived from the local
# realm instrument, or the global instrument, as apporpriate.
#
sub _get_field_value {
    my($self, $field) = @_;
    return defined($self->get('instrument_id'))
	    ? $self->get_model('Instrument')->get($field)
	    : $self->get($field);
}

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
