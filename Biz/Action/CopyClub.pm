# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Action::CopyClub;
use strict;
$Bivio::Biz::Action::CopyClub::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Action::CopyClub - copies all club data to a new club

=head1 SYNOPSIS

    use Bivio::Biz::Action::CopyClub;
    Bivio::Biz::Action::CopyClub->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::Action>

=cut

use Bivio::Biz::Action;
@Bivio::Biz::Action::CopyClub::ISA = ('Bivio::Biz::Action');

=head1 DESCRIPTION

C<Bivio::Biz::Action::CopyClub> copies all club data to a new club. Useful for
demo clubs.

=cut

#=IMPORTS
use Bivio::Auth::RealmType;
use Bivio::Biz::Model::Club;
use Bivio::Biz::Model::Entry;
use Bivio::Biz::Model::MailMessage;
use Bivio::Biz::Model::MemberEntry;
use Bivio::Biz::Model::RealmAccount;
use Bivio::Biz::Model::RealmAccountEntry;
use Bivio::Biz::Model::RealmInstrument;
use Bivio::Biz::Model::RealmInstrumentEntry;
use Bivio::Biz::Model::RealmInstrumentValuation;
use Bivio::Biz::Model::RealmTransaction;
use Bivio::Biz::Model::RealmUser;
use Bivio::SQL::Connection;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Uses the 'source', 'target_name', and 'target_full_name' request
parameters to copy club data.

=cut

sub execute {
    my($self, $req) = @_;

    my($source) = $req->get('source');
    my($source_id) = $source->get('realm_id');
    my($name) = $req->get('target_name');
    my($full_name) = $req->get('target_full_name');

    my($old_club) = Bivio::Biz::Model::Club->new($req);
    $old_club->unauth_load(club_id => $source_id)
	    || die("can't load source club $source_id");
    my($new_club) = Bivio::Biz::Model::Club->new($req);
    $new_club->create({
	full_name => $full_name,
	kbytes_in_use => $old_club->get('kbytes_in_use'),
	max_storage_kbytes => $old_club->get('max_storage_kbytes')
    });
    my($new_realm) = Bivio::Biz::Model::RealmOwner->new($req);
    $new_realm->create({
	realm_id => $new_club->get('club_id'),
	name => $name,
	realm_type => Bivio::Auth::RealmType::CLUB()
    });

    my($id_map) = {$source_id => $new_realm->get('realm_id')};

    # mail messages
    _copy($id_map, 'mail_message', {club_id => $source_id},
	    Bivio::Biz::Model::MailMessage->new($req));
    Bivio::Biz::Model::MailMessage->copy_club($source, $new_realm);

    # transactions and base entries
    my($ids) = _copy($id_map, 'realm_transaction', {realm_id => $source_id},
	    Bivio::Biz::Model::RealmTransaction->new($req));
    foreach my $id (@$ids) {
	_copy($id_map, 'entry', {realm_transaction_id => $id},
		Bivio::Biz::Model::Entry->new($req));
    }

    # instruments, valuations, and entries
    $ids = _copy($id_map, 'realm_instrument', {realm_id => $source_id},
	    Bivio::Biz::Model::RealmInstrument->new($req));
    foreach my $id (@$ids) {
	_copy($id_map, 'realm_instrument_valuation',
		{realm_instrument_id => $id},
		Bivio::Biz::Model::RealmInstrumentValuation->new($req));
	_copy($id_map, 'realm_instrument_entry',
		{realm_instrument_id => $id},
		Bivio::Biz::Model::RealmInstrumentEntry->new($req),
		'entry_id');
    }

    # accounts and entries
    $ids = _copy($id_map, 'realm_account', {realm_id => $source_id},
	    Bivio::Biz::Model::RealmAccount->new($req));
    foreach my $id (@$ids) {
	_copy($id_map, 'realm_account_entry', {realm_account_id => $id},
		Bivio::Biz::Model::RealmAccountEntry->new($req),
		'entry_id');
    }

    # members and entries
    _copy($id_map, 'realm_user', {realm_id => $source_id},
	    Bivio::Biz::Model::RealmUser->new($req));
    my($sth) = Bivio::SQL::Connection->execute(
	    'select user_id from realm_user_t where realm_id=?', [$source_id]);
    my($row);
    while ($row = $sth->fetchrow_arrayref) {
	my($user_id) = $row->[0];
	# users map to themselves, they are not copied
	$id_map->{$user_id} = $user_id;
	_copy($id_map, 'member_entry', {user_id => $user_id},
		Bivio::Biz::Model::MemberEntry->new($req), 'entry_id');
    }
    return;
}

#=PRIVATE METHODS

# _copy(hash_ref id_map, string table_base, hash_ref key_map, Bivio::Biz::PropertyModel model, string extra_field) : array_ref
#
# Copies all the entries with the parent keys of the 'key_map' to a
# new Model. Returns a set of ids for the source models.
#
sub _copy {
    my($id_map, $table_base, $key_map, $model, $extra_field) = @_;

    my($select) = 'select ';
    my($fields) = $model->get_keys;
    foreach my $field (@$fields) {
	$select .= $model->get_field_type($field)->from_sql_value($field)
		.',';
    }
    chop($select);
    my(@keys) = keys(%$key_map);
    my(@values) = values(%$key_map);
    $select .= ' from '.$table_base.'_t where '.join('=? and', @keys).'=?';
    my($sth) = Bivio::SQL::Connection->execute($select, \@values);
    my($result) = [];
    my($row);

    while ($row = $sth->fetchrow_arrayref) {
	my($properties) = {};
	for (my($i) = 0; $i < int(@$fields); $i++ ) {
	    $properties->{$fields->[$i]} = $row->[$i];
	}
	my($source_id) = $properties->{$table_base."_id"};
	if (defined($source_id)) {
	    push(@$result, $source_id);
	}

	# change key field and insert into database
	foreach my $key (@keys) {
	    $properties->{$key} = $id_map->{$properties->{$key}};
	}
	# also change extra field if present
	if (defined($extra_field)) {
	    $properties->{$extra_field} =
		    $id_map->{$properties->{$extra_field}};
	    # skip if not present (not part of realm)
	    next unless defined($properties->{$extra_field});
	}
	$model->create($properties);

	if (defined($source_id)) {
	    $id_map->{$source_id} = $model->get($table_base."_id");
	}
    }
    return $result;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;

=begin comment

use Bivio::Agent::TestRequest;
use Bivio::IO::Config;

Bivio::IO::Config->initialize();

my($req) = Bivio::Agent::TestRequest->new({
    source_club_id => 5400002,
    target_club_id => 5600002,
});

Bivio::Biz::Action::CopyClub->get_instance()->execute($req);
Bivio::SQL::Connection->commit();

=cut

