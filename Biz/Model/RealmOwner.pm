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
    return $result;
}

=for html <a name="get_unit_value"></a>

=head2 get_unit_value(Bivio::Type::Date date) : string

Returns the unit value for the realm on the specified date.

=cut

sub get_unit_value {
    my($self, $date) = @_;

    Carp::croak('missing date parameter') unless $date;

    my($units) = $self->get_units($date);
    return $units == 0 ? 0
#	    : $self->get_value($date) / $units;
	    : Bivio::Type::Amount->div($self->get_value($date), $units);
}

=for html <a name="get_units"></a>

=head2 get_units(Bivio::Type::Date date) : string

Returns the total number of units purchased in the realm up to the specified
date.

=cut

sub get_units {
    my($self, $date) = @_;

    Carp::croak('missing date parameter') unless $date;

    my($sth) = Bivio::SQL::Connection->execute(
	    'select sum(member_entry_t.units) from realm_transaction_t, entry_t, member_entry_t where realm_transaction_t.realm_transaction_id = entry_t.realm_transaction_id and entry_t.entry_id = member_entry_t.entry_id and realm_transaction_t.realm_id=? and realm_transaction_t.date_time <= '
	    .Bivio::Type::Date->to_sql_value('?'),
	    [$self->get('realm_id'),
		    Bivio::Type::Date->to_sql_param($date)]);

    return $sth->fetchrow_arrayref()->[0] || '0';
}

=for html <a name="get_value"></a>

=head2 get_value(Bivio::Type::Date date) : string

Returns the realm's value on the specified date.

=cut

sub get_value {
    my($self, $date) = @_;

    Carp::croak('missing date parameter') unless $date;

#TODO: investigating caching this value in the request
    my($value) = $self->get_tax_basis(Bivio::Type::EntryClass->CASH, $date);

    my($instruments) = $self->get_instruments_info();
    my($inst);
    foreach $inst (@$instruments) {
	my($id) = $inst->[0];
	my($price) = Bivio::Biz::Model::RealmInstrument
		->get_share_price($id, $date, $self);
#	$value += Bivio::Biz::Model::RealmInstrument
#		->get_number_of_shares($id, $date) * $price;
	$value = Bivio::Type::Amount->add($value,
		Bivio::Type::Amount->mul(Bivio::Biz::Model::RealmInstrument
		->get_number_of_shares($id, $date), $price));
    }
    return $value;
}

=for html <a name="get_tax_basis"></a>

=head2 get_tax_basis(EntryClass class, Bivio::Type::Date date) : string

Returns the total tax basis of the specified entry class up to the specified
date.

=cut

sub get_tax_basis {
    my($self, $class, $date) = @_;

    Carp::croak('missing date parameter') unless $date;

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
