# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ForumUserEditDAVList;
use strict;
use base 'Bivio::Biz::Model::EditDAVList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub CSV_COLUMNS {
    return [qw(Email.email mail_recipient administrator RealmUser.user_id)];
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
	'RealmUser.role' => $new->{administrator} ? Bivio::Auth::Role->ADMINISTRATOR : undef,
    });
    $self->new_other('RealmUser')->unauth_delete({
	realm_id => $f->get('RealmUser.realm_id'),
	user_id => $f->get('User.user_id'),
	role => Bivio::Auth::Role->MAIL_RECIPIENT,
    }) unless $new->{mail_recipient};
    return;
}

sub row_delete {
    my($self, $old) = @_;
    my($req) = $self->get_request;
    $self->new_other('ForumUserDeleteForum')->process({
	'RealmUser.realm_id' => $req->get('auth_id'),
	'User.user_id' => $old->{'RealmUser.user_id'},
    });
    return;
}

sub row_update {
    my($self, $new, $old) = @_;
    return 'Email may not be updated via this interface'
	unless $new->{'Email.email'} eq $old->{'Email.email'};
    my($req) = $self->get_request;
    foreach my $r (qw(mail_recipient administrator)) {
	next unless $new->{$r} xor $old->{$r};
	my($op) = $new->{$r} ? 'create' : 'unauth_delete';
	$self->new_other('RealmUser')->$op({
	    realm_id => $req->get('auth_id'),
	    user_id => $old->{'RealmUser.user_id'},
	    role => Bivio::Auth::Role->from_name($r),
	});
    }
    return;
}

1;
