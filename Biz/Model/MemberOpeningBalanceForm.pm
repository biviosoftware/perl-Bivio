# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::MemberOpeningBalanceForm;
use strict;
$Bivio::Biz::Model::MemberOpeningBalanceForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::MemberOpeningBalanceForm - opening balance entry form

=head1 SYNOPSIS

    use Bivio::Biz::Model::MemberOpeningBalanceForm;
    Bivio::Biz::Model::MemberOpeningBalanceForm->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::MemberOpeningBalanceForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::MemberOpeningBalanceForm> opening balance entry form

=cut

#=IMPORTS
use Bivio::Biz::Model::MemberEntry;
use Bivio::Biz::Model::RealmTransaction;
use Bivio::SQL::Constraint;
use Bivio::Type::Amount;
use Bivio::Type::Date;
use Bivio::Type::EntryClass;
use Bivio::Type::EntryType;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute_input"></a>

=head2 execute_input()

Creates member entries for amount paid, units, and earnings distributions.

=cut

sub execute_input {
    my($self) = @_;
    my($req) = $self->get_request();
    my($realm) = $req->get('auth_realm')->get('owner');

    my($properties) = $self->internal_get();
    my($paid) = Bivio::Type::Amount->round(
	    $properties->{'paid'} || 0, 2);
    my($earnings) = Bivio::Type::Amount->round(
	    $properties->{'earnings'} || 0, 2);
    my($units) = $properties->{'MemberEntry.units'};
    my($member) = $req->get('target_realm_owner');

    # create the transaction
    my($transaction) = Bivio::Biz::Model::RealmTransaction->new($req);
    $transaction->create({
	source_class => Bivio::Type::EntryClass::MEMBER(),
	date_time => $properties->{'RealmTransaction.date_time'},
	remark => $properties->{'RealmTransaction.remark'},
    });

    # two entries, one for paid and units, the other for earnings
    my($member_entry) = Bivio::Biz::Model::MemberEntry->new($req);
    $member_entry->create_entry($transaction, {
	entry_type => Bivio::Type::EntryType::MEMBER_OPENING_BALANCE(),
	amount => $paid,
	user_id => $member->get('realm_id'),
	units => $units,
	# no valuation date
    });

    if ($earnings != 0) {
	$member_entry->create_entry($transaction, {
	    entry_type =>
	    Bivio::Type::EntryType::MEMBER_OPENING_EARNINGS_DISTRIBUTION(),
	    amount => $earnings,
	    user_id => $member->get('realm_id'),
	});
    }
    # need to update units after this date
    $realm->audit_units($properties->{'RealmTransaction.date_time'});
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	require_context => 1,
	visible => [
	    {
		name => 'RealmTransaction.date_time',
		type => 'Bivio::Type::Date',
		constraint => Bivio::SQL::Constraint::NOT_NULL(),
	    },
	    {
		name => 'earnings',
		type => 'Bivio::Type::Amount',
		constraint => Bivio::SQL::Constraint::NONE(),
	    },
	    {
		name => 'paid',
		type => 'Bivio::Type::Amount',
		constraint => Bivio::SQL::Constraint::NONE(),
	    },
	    'MemberEntry.units',
	    'RealmTransaction.remark'
	],
	auth_id =>
	    ['RealmTransaction.realm_id', 'RealmOwner.realm_id',
	        'Entry.realm_id'],
	primary_key => [
	    ['RealmTransaction.realm_transaction_id',
		     'Entry.realm_transaction_id']
	],
    };
}

=for html <a name="validate"></a>

=head2 validate(boolean is_create)

Validates field values.

=cut

sub validate {
    my($self) = @_;

    $self->validate_not_negative('paid');
    $self->validate_not_negative('earnings');
    $self->validate_greater_than_zero('MemberEntry.units');

    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
