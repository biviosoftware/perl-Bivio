# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::ListModel::AccountValuationList;
use strict;
$Bivio::Biz::ListModel::AccountValuationList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::ListModel::AccountValuationList - cash account valuations

=head1 SYNOPSIS

    use Bivio::Biz::ListModel::AccountValuationList;
    Bivio::Biz::ListModel::AccountValuationList->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::Biz::ListModel::AccountValuationList::ISA = ('Bivio::Biz::ListModel');

=head1 DESCRIPTION

C<Bivio::Biz::ListModel::AccountValuationList>

=cut

#=IMPORTS
use Bivio::Agent::Request;
use Bivio::Type::Amount;
use Bivio::Type::DateTime;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize()

All local fields.

=cut

sub internal_initialize {

    return {
	version => 1,
	other => [
	    {
	        name => 'name',
   	        type => 'Bivio::Type::String',
	        constraint => Bivio::SQL::Constraint::NONE(),
	    },
	    {
	        name => 'total_cost',
   	        type => 'Bivio::Type::Amount',
	        constraint => Bivio::SQL::Constraint::NONE(),
	    },
	    {
	        name => 'total_value',
   	        type => 'Bivio::Type::Amount',
	        constraint => Bivio::SQL::Constraint::NONE(),
	    },
	    {
	        name => 'percent',
   	        type => 'Bivio::Type::Amount',
	        constraint => Bivio::SQL::Constraint::NONE(),
	    },
	],
    };
}

=for html <a name="internal_load"></a>

=head2 internal_load(array_ref rows, Bivio::SQL::ListQuery query)

Loads the account valuation list with data. Uses the date parameters
to load values.

=cut

sub internal_load {
    my($self, $rows, $query) = @_;

    $self->SUPER::internal_load($rows, $query);

    my($req) = Bivio::Agent::Request->get_current();
    my($realm) = $req->get('auth_realm')->get('owner');

#TODO: get date from query if present
#TODO: is time() the correct default?
    my($date) = Bivio::Type::DateTime->to_sql_param(time());

#TODO: may want this on the request?
    my($realm_value) = $req->unsafe_get('realm_value')
	    || $realm->get_value($date);
    $req->put('realm_value' => $realm_value);

    # first get all the valuation accounts for the realm
    my($sth) = Bivio::SQL::Connection->execute(
	    'select realm_account_t.realm_account_id, realm_account_t.name from realm_account_t where realm_account_t.in_valuation=1 and realm_account_t.realm_id=? order by realm_account_t.name',
	    [$realm->get('realm_id')]);

    my($account_info) = [];

    my($row);
    while ($row = $sth->fetchrow_arrayref) {
	my($id, $name) = @$row;
	push(@$account_info, [$id, $name]);
    }

    my($params) = '';
    my($values) = [];
    foreach my $info (@$account_info) {
	push(@$values, $info->[0]);
	$params .= '?,';
    }
    # remove extra ,
    chop($params);
    push(@$values, $date);

    # then get the value of the accounts (no entry will exist for 0 value)
    my($sql) = 'select realm_account_entry_t.realm_account_id, sum(entry_t.amount) from realm_transaction_t, entry_t, realm_account_entry_t where realm_transaction_t.realm_transaction_id = entry_t.realm_transaction_id and entry_t.entry_id = realm_account_entry_t.entry_id and realm_account_entry_t.realm_account_id in ('.$params.') and realm_transaction_t.dttm <= TO_DATE(?,\'J SSSSS\') group by realm_account_entry_t.realm_account_id';
    $sth = Bivio::SQL::Connection->execute($sql, $values);

    my($account_value) = {};
    while ($row = $sth->fetchrow_arrayref) {
	my($id, $value) = @$row;
	$account_value->{$id} = $value;
    }

    # iterate accounts alphabetically
    foreach my $info (@$account_info) {
	my($value) = $account_value->{$info->[0]} || '0';
	push(@$rows, {name => $info->[1],
	    total_cost => $value,
	    total_value => $value,
#TODO: use Math::BigInt
	    percent => $value * 100 / $realm_value});
    }

    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
