# Copyright (c) 2005 bivio Software.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::Forum;
use strict;
use base ('Bivio::Biz::PropertyModel');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub MAIL_FOLDER {
    return '/Mail';
}

sub PUBLIC_FOLDER {
    return '/Public';
}

sub create_realm {
    my($self, $realm_owner) = @_;
    my($req) = $self->get_request;
    my($ro) = $self->new_other('RealmOwner')->create({
	%$realm_owner,
	realm_type => Bivio::Auth::RealmType->FORUM,
	realm_id => $self->create({
	    parent_realm_id => $req->get('auth_id'),
	})->get('forum_id'),
    });
    my($f) = $self->new_other('RealmFile');
    foreach my $folder (qw(MAIL_FOLDER PUBLIC_FOLDER)) {
	$f->create_folder({
	    path => $self->$folder(),
	    realm_id => $self->get('forum_id'),
	    ($folder eq 'MAIL_FOLDER' ? 'is_read_only' : 'is_public') => 1,
	});
    }
    foreach my $admin_id (
	@{$self->new_other('RealmAdminList')->map_iterate(
	    sub {shift->get('RealmUser.user_id')},
	)},
    ) {
	$self->new_other('ForumUserAddForm')->execute($req, {
	    'RealmUser.realm_id' => $self->get('forum_id'),
	    'User.user_id' => $admin_id,
	    role => Bivio::Auth::Role->ADMINISTRATOR,
	});
    }
    # Reset state after ForumUserAddForm messed it up
    $self->put_on_request;
    $ro->put_on_request;
    return ($self, $ro);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	table_name => 'forum_t',
	columns => {
            forum_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
	    parent_realm_id => ['RealmOwner.realm_id', 'NOT_NULL'],
        },
	auth_id => 'forum_id',
    });
}

sub update {
    my($self, $values) = @_;
    $values->{name_lc} = lc($values->{name})
	if defined($values->{name});
    return shift->SUPER::update(@_);
}

1;
