# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::AccountInterestForm;
use strict;
$Bivio::Biz::Model::AccountInterestForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::AccountInterestForm - an account interest form

=head1 SYNOPSIS

    use Bivio::Biz::Model::AccountInterestForm;
    Bivio::Biz::Model::AccountInterestForm->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::AccountInterestForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::AccountInterestForm>

=cut

#=IMPORTS
use Bivio::TypeError;
use Bivio::UI::HTML::Format::Date;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Agent::Request req) : Bivio::Biz::Model::AccountInterestForm

Creates an account interest income form.

=cut

sub new {
    my($self) = &Bivio::Biz::FormModel::new(@_);
    $self->{$_PACKAGE} = {};

#TODO: rework when defaults available
    my($properties) = $self->internal_get;
    # default dttm to now
    $properties->{'RealmTransaction.dttm'} =
	    Bivio::UI::HTML::Format::Date->get_widget_value(
		    Bivio::Type::Date->now());

    return $self;
}

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create()

Creates an account interest transaction.

=cut

sub create {
    my($self) = @_;

    my($properties) = $self->internal_get();
    my($req) = $self->get_request();

    # get the target account
    my($account) = Bivio::Biz::Model::RealmAccount->new($req);
    $account->load(realm_account_id => $req->get('query')->{pk});

    # create the transaction
    my($transaction) = Bivio::Biz::Model::RealmTransaction->new($req);
    my($values) = $self->get_model_properties('RealmTransaction');
    my($realm) = $req->get('auth_realm')->get('owner');
    $values->{realm_id} = $realm->get('realm_id');
    $values->{source_class} = Bivio::Type::EntryClass::CASH();
    $values->{user_id} = $req->get('auth_user')->get('realm_id');
    $transaction->create($values);

    # create the entry and account_entry
    my($entry) = Bivio::Biz::Model::Entry->new($req);
    $values = $self->get_model_properties('Entry');
    $values->{realm_transaction_id} = $transaction->get(
	    'realm_transaction_id');
    $values->{class} = Bivio::Type::EntryClass::CASH();
    $values->{entry_type} = Bivio::Type::EntryType->CASH_INTEREST();
    $values->{tax_category} = Bivio::Type::TaxCategory::INTEREST();

    # doesn't affect club's tax basis if account is part of valuation
    $values->{tax_basis} = $account->get('in_valuation');
    $entry->create($values);

    $values = {realm_account_id => $account->get('realm_account_id')};
    $values->{entry_id} = $entry->get('entry_id');
    my($account_entry) = Bivio::Biz::Model::RealmAccountEntry->new($req);
    $account_entry->create($values);

    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	visible => [
	    {
		name => 'RealmTransaction.dttm',
		type => 'Bivio::Type::Date',
		constraint => Bivio::SQL::Constraint::NOT_NULL(),
	    },
	    'Entry.amount',
	    'RealmTransaction.remark'
	],
	auth_id =>
	    ['RealmTransaction.realm_id', 'RealmOwner.realm_id'],
	primary_key => [
	    'RealmTransaction.realm_transaction_id',
	],
    };
}

=for html <a name="validate"></a>

=head2 validate(boolean is_create)

Checks the form property values.  Puts errors on the fields
if there are any.

=cut

sub validate {
    my($self) = @_;

    my($amount) = $self->get_model_properties('Entry')->{amount};

    # make sure the payment amount is > 0
    $self->internal_put_error('Entry.amount',
	    Bivio::TypeError::GREATER_THAN_ZERO())
	    unless $amount > 0;

    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
