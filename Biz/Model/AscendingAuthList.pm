# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::AscendingAuthList;
use strict;
use base 'Bivio::Biz::ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_GID);

sub find_row_by_id {
    my($self, $id) = @_;
    my($pk) = @{$self->get_info('primary_key_names')};
    return $self->get_field_type($pk)->is_specified($id)
	&& $self->find_row_by($pk, $id);
}

sub internal_initialize {
    my($self) = @_;
    $_GID = Bivio::Auth::Realm->get_general->get('id');
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	# We expect this to be overwritten
	primary_key => ['RealmOwner.realm_id'],
	# Make sure this is in the select, since it can vary, not like
	# regular auth_id which is constant
	other => [
	    [$self->AUTH_ID_FIELD, 'RealmOwner.realm_id'],
	    # Convenient for generating links
	    'RealmOwner.name',
	    'RealmOwner.realm_type',
	],
    });
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    my($req) = $self->get_request;
    $stmt->where($stmt->IN(
	$self->AUTH_ID_FIELD,
	[
	    $_GID,
	    $req->get_nested(qw(auth_realm type))->eq_forum
		? _ascend($self->new_other('Forum'), $req->get('auth_id'))
		: $req->get('auth_id'),
        ],
    ));
    return;
}

sub _ascend {
    my($f, $id) = @_;
    return $_GID ne $id && $f->unauth_load({forum_id => $id})
        ? ($id, _ascend($f, $f->get('parent_realm_id'))) : ();
}

1;
