# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::ImportedTransactionList;
use strict;
$Bivio::Biz::Model::ImportedTransactionList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::ImportedTransactionList::VERSION;

=head1 NAME

Bivio::Biz::Model::ImportedTransactionList - imported account sync txns

=head1 SYNOPSIS

    use Bivio::Biz::Model::ImportedTransactionList;

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::Biz::Model::ImportedTransactionList::ISA = ('Bivio::Biz::ListModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::ImportedTransactionList> imported account sync txns

=cut

#=IMPORTS
use Bivio::Biz::Action::EditTransaction;
use Bivio::Biz::Model::AccountTransactionList;
use Bivio::Type::EntryType;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_REVIEW_KEY) = $_PACKAGE.'-review';

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Agent::Request) : Bivio::Biz::Model::ImportedTransactionList

Creates a new imported transaction list.

=cut

sub new {
    my($proto, $req) = @_;
    my($self) = Bivio::Biz::ListModel::new(@_);
    $self->{$_PACKAGE} = {
	review => ($req && $req->unsafe_get($_REVIEW_KEY))
	? $req->get($_REVIEW_KEY) : undef,
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="can_edit"></a>

=head2 can_edit() : boolean

Returns true if the current row can be edited.

=cut

sub can_edit {
    my($self) = @_;
    return Bivio::Biz::Action::EditTransaction->can_edit(
	    $self->get('Entry.entry_type'));
}

=for html <a name="execute_load_all_unassigned"></a>

=head2 execute_load_all_unassigned(Bivio::Agent::Request) : boolean

Only loads transactions which have not been identified.

=cut

sub execute_load_all_unassigned {
    my($proto, $req) = @_;
    $req->put($_REVIEW_KEY => 'unassigned');
    return $proto->execute_load_all_with_query($req);
}

=for html <a name="execute_load_review_page"></a>

=head2 static execute_load_review_page(Bivio::Agent::Request req) : boolean

Only loads transactions which have been identified.

=cut

sub execute_load_review_page {
    my($proto, $req) = @_;
    $req->put($_REVIEW_KEY => 'identified');
    return $proto->execute_load_page($req);
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	auth_id => [qw(RealmTransaction.realm_id)],
	order_by => [qw(
            RealmTransaction.date_time
            AccountSync.sync_key
            RealmTransaction.realm_transaction_id
        )],
	primary_key => [
	    [qw(Entry.entry_id)],
	],
	other => [
	    qw(
            RealmTransaction.source_class
            RealmTransaction.remark
            Entry.amount
            Entry.class
            Entry.entry_type
            Entry.tax_category
            AccountSync.sync_key
            RealmAccount.realm_account_id
	    ),
	    {
		name => 'RealmTransaction.realm_transaction_id',
		sort_order => 0,
	    },
	    [qw{RealmTransaction.realm_transaction_id
                Entry.realm_transaction_id}],
	    [qw{Entry.entry_id RealmAccountEntry.entry_id}],
	    [qw{RealmAccountEntry.realm_account_id
                RealmAccount.realm_account_id}],
	    [qw{RealmTransaction.realm_transaction_id
                AccountSync.realm_transaction_id}],
	],
    };
}

=for html <a name="internal_load"></a>

=head2 internal_load(array_ref rows, Bivio::SQL::ListQuery query)

Generates the appropriate remark for entries whose source is an instrument
or member.

=cut

sub internal_load {
    my($self, $rows, $query) = @_;
    $self->SUPER::internal_load($rows, $query);
    Bivio::Biz::Model::AccountTransactionList->generate_remarks(
	    $self, 'RealmTransaction.remark', 1);
    return;
}

=for html <a name="internal_pre_load"></a>

=head2 internal_pre_load(Bivio::SQL::ListQuery query, Bivio::SQL::ListSupport support, array_ref params) : string

Creates 'where' which gets entries after a specified valuation date,
ordered by valuation date.

=cut

sub internal_pre_load {
    my($self, $query, $support, $params) = @_;
    my($fields) = $self->{$_PACKAGE};

    # show all if no review type specified
    return '' unless $fields->{review};

    # either show only unassigned or everything except unassigned
    my($unassigned_types) = Bivio::Type::EntryType->get_unassigned_types;
    push(@$params, map {$_ = $_->as_int} @$unassigned_types);

    my($where) = 'entry_t.entry_type '
	    .($fields->{review} eq 'identified' ? 'NOT ' : '')
		    .'IN ('.('?,' x int(@$unassigned_types));
    chop($where);
    return $where.')';
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
