# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
# Generated by ../generate.PL on Wed Aug 18  7:57:50 1999
# from tables.sql,v 1.13 1999/08/13 17:06:21 moeller Exp 
package Bivio::Biz::Model::RealmAccount;
use strict;
$Bivio::Biz::Model::RealmAccount::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::RealmAccount::VERSION;

=head1 NAME

Bivio::Biz::Model::RealmAccount - interface to realm_account_t SQL table

=head1 SYNOPSIS

    use Bivio::Biz::Model::RealmAccount;
    Bivio::Biz::Model::RealmAccount->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::RealmAccount::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::RealmAccount> is the create, read, update,
and delete interface to the C<realm_account_t> table.

=cut


=head1 CONSTANTS

=cut

=for html <a name="BANK"></a>

=head2 BANK : string

Predefined bank account name.

=cut

sub BANK {
    return 'Bank';
}

=for html <a name="BROKER"></a>

=head2 BROKER : string

Predefined broker account name.

=cut

sub BROKER {
    return 'Broker';
}

=for html <a name="PETTY_CASH"></a>

=head2 PETTY_CASH : string

Predefined petty cash account name.

=cut

sub PETTY_CASH {
    return 'Petty Cash';
}

=for html <a name="SUSPENSE"></a>

=head2 SUSPENSE : string

Predefined suspense account name

=cut

sub SUSPENSE {
    return 'Suspense';
}

#=IMPORTS
use Bivio::SQL::Connection;
use Bivio::Type::DateTime;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_value"></a>

=head2 get_value(string date) : string

Returns the account's balance on the specified date.

=cut

sub get_value {
    my($self, $date) = @_;

    Carp::croak('missing date parameter') unless $date;

    my($sth) = Bivio::SQL::Connection->execute('
	    SELECT SUM(entry_t.amount)
            FROM realm_transaction_t, entry_t, realm_account_entry_t
            WHERE realm_transaction_t.realm_transaction_id
                = entry_t.realm_transaction_id
            AND entry_t.entry_id = realm_account_entry_t.entry_id
            AND realm_transaction_t.realm_id=?
            AND realm_account_entry_t.realm_account_id=?
            AND realm_transaction_t.date_time <= '
	    .Bivio::Type::DateTime->to_sql_value('?'),
	    [$self->get_request->get('auth_id'),
		    $self->get('realm_account_id'),
		    Bivio::Type::DateTime->to_sql_param($date)]);

    return $sth->fetchrow_arrayref()->[0] || '0';
}

=for html <a name="in_valuation"></a>

=head2 in_valuation() : boolean

Returns true is the current account is in the club's valuation.

=cut

sub in_valuation {
    my($self) = @_;
    return $self->get('in_valuation');
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'realm_account_t',
	columns => {
            realm_account_id => ['PrimaryId', 'PRIMARY_KEY'],
            realm_id => ['PrimaryId', 'NOT_NULL'],
            name => ['Line', 'NOT_NULL'],
            tax_free => ['Boolean', 'NOT_NULL'],
            in_valuation => ['Boolean', 'NOT_NULL'],
            institution_id => ['PrimaryId', 'NONE'],
            account_number => ['Name', 'NONE'],
            external_password => ['Name', 'NONE'],
        },
	auth_id => 'realm_id',
    };
}

=for html <a name="create_initial"></a>

=head2 create_initial()

=head2 create_initial(string realm_id)

Create the initial accounts (BANK, BROKER, SUSPENSE, and PETTY_CASH)
for the current request's realm.

=cut

sub create_initial {
    my($self, $realm_id) = @_;
    $realm_id ||= $self->get_request->get('auth_id');

    foreach my $name (BANK(), BROKER(), SUSPENSE(), PETTY_CASH()) {
	$self->create({
	    realm_id => $realm_id,
	    name => $name,
	    tax_free => 0,
	    in_valuation => $name eq PETTY_CASH() ? 0 : 1,
	});
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
