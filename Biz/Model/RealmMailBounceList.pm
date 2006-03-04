# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmMailBounceList;
use strict;
use base 'Bivio::Biz::ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute {
    my($proto, $req) = @_;
    $proto->new($req)->load_all({
	parent_id => $req->get_nested(
	    qw(Model.RealmMailList RealmMail.realm_file_id)),
    });
    return 0;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        parent_id => ['RealmMailBounce.realm_file_id'],
	primary_key => ['RealmMailBounce.email'],
	order_by => [qw(
	    RealmMailBounce.email
	    RealmMailBounce.reason
	    RealmMailBounce.modified_date_time
	    Email.email
	)],
	other => [
	    [qw(RealmMailBounce.user_id Email.realm_id)],
	],
	auth_id => ['RealmMailBounce.realm_id'],
    });
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    $stmt->EQ(
	'Email.location',
	$self->get_instance('Email')->DEFAULT_LOCATION,
    );
    return shift->SUPER::internal_prepare_statement(@_);
}

1;
