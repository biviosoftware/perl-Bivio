# Copyright (c) 2005-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ForumUserEditDAVList;
use strict;
use Bivio::Base 'Model.EditDAVList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_R) = b_use('Auth.Role');

sub CSV_COLUMNS {
    return [qw(Email.email mail_recipient file_writer administrator RealmUser.user_id)];
}

sub LIST_CLASS {
    return 'ForumUserList';
}

sub row_create {
    my($self, $new) = @_;
    my($f) = $self->new_other('ForumUserAddForm');
    my($req) = $self->get_request;
    $f->process({
	'Email.email' => $new->{'Email.email'},
	'RealmUser.realm_id' => $req->get('auth_id'),
	map(($_ => $new->{$_}), qw(administrator file_writer)),
	not_mail_recipient => !$new->{mail_recipient},
    });
    return;
}

sub row_delete {
    my($self, $old) = @_;
    my($req) = $self->get_request;
    $self->new_other('ForumUserDeleteForm')->process({
	'RealmUser.realm_id' => $req->get('auth_id'),
	'User.user_id' => $old->{'RealmUser.user_id'},
    });
    return;
}

sub row_update {
    my($self, $new, $old) = @_;
    return 'Email may not be updated via this interface'
	unless $new->{'Email.email'} eq $old->{'Email.email'};
    $self->new_other('GroupUserForm')->process({
	map(($_ => $new->{$_}), (qw(mail_recipient file_writer))),
	'RealmUser.role' => _role($new),
	'RealmUser.user_id' => $old->{'RealmUser.user_id'},
	current_main_role => _role($old),
    });
    return;
}

sub _role {
    my($values) = @_;
    return $_R->from_name($values->{administrator} ? 'ADMINISTRATOR' : 'MEMBER');
}

1;
