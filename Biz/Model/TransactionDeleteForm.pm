# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::TransactionDeleteForm;
use strict;
$Bivio::Biz::Model::TransactionDeleteForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::TransactionDeleteForm::VERSION;

=head1 NAME

Bivio::Biz::Model::TransactionDeleteForm - deletes a transaction and entries

=head1 SYNOPSIS

    use Bivio::Biz::Model::TransactionDeleteForm;
    Bivio::Biz::Model::TransactionDeleteForm->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::TransactionDeleteForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::TransactionDeleteForm> deletes a transaction and entries

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::Auth::Role;
use Bivio::Biz::Accounting::Audit;
use Bivio::Biz::Accounting::InstrumentAudit;
use Bivio::Societas::Biz::Model::Entry;
use Bivio::Societas::Biz::Model::MemberEntry;
use Bivio::Societas::Biz::Model::RealmInstrument;
use Bivio::Biz::Model::RealmUser;
use Bivio::Die;
use Bivio::IO::Alert;
use Bivio::SQL::Connection;
use Bivio::Type::EntryClass;
use Bivio::Type::EntryType;
use Bivio::Type::Honorific;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Agent::Request req) : Bivio::Biz::Model::TransactionDeleteForm

Creates a new TransactionDeleteForm.

=cut

sub new {
    my($self) = Bivio::Biz::FormModel::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute_empty"></a>

=head2 execute_empty() : boolean

Loads the entry when entering the form for the first time.

=cut

sub execute_empty {
    my($self) = @_;
    _check_exists($self);
    return;
}

=for html <a name="execute_ok"></a>

=head2 execute_ok()

Deletes the selected entry, its transactions and all its entries.

=cut

sub execute_ok {
    my($self) = @_;
    my($entry) = _check_exists($self);

    # delete the related transaction and all its entries
    my($txn) = $entry->get_model('RealmTransaction');
    my($date) = $txn->get('date_time');

    _pre_delete($self, $txn);
    $txn->cascade_delete;
    _post_delete($self, $date);

    return;
}

=for html <a name="execute_unwind"></a>

=head2 execute_unwind()

Loads the entry when returning from another form (like preferences).

=cut

sub execute_unwind {
    my($self) = @_;
    _check_exists($self);
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    my($self) = @_;
    my($info) = {
	version => 2,
	require_context => 1,
	auth_id => ['RealmTransaction.realm_id', 'RealmOwner.realm_id'],
    };
    return $self->merge_initialize_info(
	    $self->SUPER::internal_initialize, $info);
}

#=PRIVATE METHODS

# _check_exists() : Bivio::Societas::Biz::Model::Entry
#
# Ensures that selected entry exists, if not, redirects to the cancel
# task. This handles the case where the browser's back button is used
# to return to a previously deleted item.
#
sub _check_exists {
    my($self) = @_;
    my($req) = $self->get_request;

    # try to load the entry from the query
    # if it isn't present, then log a warning and cancel out

    # loads the entry
    my($entry) = Bivio::Societas::Biz::Model::Entry->new($req);
    unless ($req->get('query') && exists($req->get('query')->{t})
	    && $entry->unsafe_load(entry_id => $req->get('query')->{t})) {
	Bivio::IO::Alert->warn("attempt to delete missing entry");
	$self->execute_cancel;
	# DOES NOT RETURN
    }
    return $entry;
}

# _get_instruments(Bivio::Societas::Biz::Model::RealmTransaction txn) : Bivio::Societas::Biz::Model::RealmInstrument
#
# Returns the instruments associated with the transaction. Dies on failure.
#
sub _get_instruments {
    my($self, $txn) = @_;

    my($result) = [];
    my($sth) = Bivio::SQL::Connection->execute("
            SELECT DISTINCT realm_instrument_entry_t.realm_instrument_id
            FROM entry_t, realm_instrument_entry_t
            WHERE entry_t.entry_id=realm_instrument_entry_t.entry_id
            AND entry_t.realm_transaction_id=?
            AND entry_t.realm_id=?",
	    [$txn->get('realm_transaction_id'),
		$self->get_request->get('auth_id'),
	    ]);
    while (my $row = $sth->fetchrow_arrayref) {
	my($id) = $row->[0];
	push(@$result, Bivio::Societas::Biz::Model::RealmInstrument->new(
		$self->get_request)->load(realm_instrument_id => $id));
    }
    Bivio::Die->die("couldn't find instruments for transaction")
		unless int(@$result) > 0;
    return $result;
}

# _post_delete(string date)
#
# Performs any post delete processing.
#
# This will audit any instruments associated with the transaction, and
# any units from the specified date forward.
#
sub _post_delete {
    my($self, $date) = @_;
    my($fields) = $self->{$_PACKAGE};

    if ($fields->{realm_instruments}) {
	foreach my $inst (@{$fields->{realm_instruments}}) {
	    _trace("auditing ", $inst->get_name) if $_TRACE;
	    Bivio::Biz::Accounting::InstrumentAudit->new($self->get_request)
			->audit($date, $inst);
	}
    }

    # need to update units after this date
    Bivio::Biz::Accounting::Audit->new($self->get_request)->audit_units($date);
    return;
}

# _pre_delete(Bivio::Societas::Biz::Model::RealmTransaction txn)
#
# Peforms and preparation prior to deleting the transaction.
#
# Deleting a full withdrawal, resets the member's state to 'member'.
#
sub _pre_delete {
    my($self, $txn) = @_;
    my($fields) = $self->{$_PACKAGE};

    if ($txn->get('source_class') == Bivio::Type::EntryClass::INSTRUMENT()) {
	_trace("pre delete instrument txn") if $_TRACE;
	# used in post delete processing
	$fields->{realm_instruments} = _get_instruments($self, $txn);
    }
    elsif ($txn->get('source_class') == Bivio::Type::EntryClass::MEMBER()) {
	_update_withdrawn_state($self, $txn);
    }
    return;
}

# _update_withdrawn_state(Bivio::Societas::Biz::Model::RealmTransaction txn)
#
# If the transaction is a full withdrawal, then the associated member
# state is returned to 'member'.
#
sub _update_withdrawn_state {
    my($self, $txn) = @_;
    my($req) = $self->get_request;

    my($sth) = Bivio::SQL::Connection->execute('
            SELECT entry_id
            FROM entry_t
            WHERE realm_transaction_id=?
            AND class=?
            AND entry_type in (?,?)
            AND realm_id=?',
	    [$txn->get('realm_transaction_id'),
		Bivio::Type::EntryClass::MEMBER->as_sql_param,
		Bivio::Type::EntryType::MEMBER_WITHDRAWAL_FULL_CASH
		->as_sql_param,
		Bivio::Type::EntryType::MEMBER_WITHDRAWAL_FULL_STOCK
		->as_sql_param,
		$req->get('auth_id'),
	    ]);

    while (my $row = $sth->fetchrow_arrayref) {
	my($entry_id) = $row->[0];

	_trace("pre delete, changing withdrawn to member state") if $_TRACE;

	# set the target status to MEMBER if it is WITHDRAWN
	my($member_entry) = Bivio::Societas::Biz::Model::MemberEntry->new($req)
		->load(entry_id => $entry_id);
	my($realm_user) = Bivio::Biz::Model::RealmUser->new($req)
		->load(user_id => $member_entry->get('user_id'));

	if ($realm_user->get('role') == Bivio::Auth::Role::WITHDRAWN()) {
	    my($honorific) = Bivio::Type::Honorific::MEMBER();
	    $realm_user->update({
		role => $honorific->get_role,
		honorific => $honorific,
	    });
	}
	last;
    }
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
