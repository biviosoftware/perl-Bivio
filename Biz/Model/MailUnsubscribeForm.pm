# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::MailUnsubscribeForm;
use strict;
use Bivio::Base 'Biz.FormModel';

my($_MAIL_RECIPIENT) = b_use('Auth.Role')->MAIL_RECIPIENT;
my($_BMM) = b_use('Type.BulletinMailMode');

sub execute_ok {
    my($self, $button) = @_;
    my($ack) = 'user_mail_unsubscribed';
    # SECURITY: Make sure there's a realm_file associated with that user, even if all_button
    my($uid) = $self->req('auth_id');
    my($rids) = [$self->get('realm_id')];
    if ($button eq 'all_button') {
	$ack = 'user_mail_unsubscribed_all';
	$rids = $self->new_other('UserRealmSubscription')->map_iterate(
	    'realm_id',
	    'unauth_iterate_start',
	    {
		user_id => $uid,
		is_subscribed => 1,
	    },
	);
    }
    foreach my $rid (@$rids) {
	$self->unsubscribe_from_bulletin_realm($uid, $rid);
    }
    return {
	acknowledgement => $ack,
    };
}

sub format_uri_for_user {
    my($self, $user_name, $realm_file_id) = @_;
    return $self->req->format_uri({
	task_id => 'USER_MAIL_UNSUBSCRIBE_FORM',
	realm => $user_name,
	path_info => $realm_file_id,
    });
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	$self->field_decl(
	    visible => [
		[qw(all_button OKButton)],
	    ],
	    other => [
		[qw(realm_display_name DisplayName)],
		[qw(realm_id RealmOwner.realm_id)],
	    ],
	),
    });
}

sub internal_pre_execute {
    my($self) = @_;
    my(@res) = shift->SUPER::internal_pre_execute(@_);
    my($rid) = $self->new_other('RealmFile')
	->unauth_load_or_die({
	    realm_file_id => ($self->req('path_info') =~ /(\d+)/)[0],
	})
	->get('realm_id');
    $self->internal_put_field(
	realm_id => $rid,
	realm_display_name => $self->new_other('RealmOwner')
	    ->unauth_load_or_die({realm_id => $rid})
	    ->get('display_name'),
    );
    return @res;
}

sub is_subscribed_to_bulletin_realm {
    return _do_bulletin_realm('unauth_load', @_);
}

sub subscribe_to_bulletin_realm {
    return _do_bulletin_realm('unauth_create_or_update', @_);
}

sub unsubscribe {
    my($self, $user_id) = @_;
    $self->new_other('UserRealmSubscription')->create_or_update({
	user_id => $user_id || $self->req('auth_user_id'),
	is_subscribed => 0,
    });
    return;
}

sub unsubscribe_from_bulletin_realm {
    my($self, $user_id, $realm_id) = @_;
    $realm_id = _bulletin_id($self, $realm_id);
    return unless $_BMM->should_leave_realm($realm_id, $self->req);
    $self->req->with_realm(
	$realm_id,
	sub {
	    $self->unsubscribe($user_id);
	    $self->new_other('RealmUser')->delete_all({user_id => $user_id});
	    return;
	},
    );
    return;
}

sub _bulletin_id {
    my($self, $realm_id) = @_;
    return $realm_id
	|| b_use('FacadeComponent.Constant')
	    ->get_value('bulletin_realm_id', $self->req)
	|| b_die('no bulletin_realm_id');
}

sub _do_bulletin_realm {
    my($method, $self, $user_id, $realm_id) = @_;
    my($bulletin_id) = _bulletin_id($self, $realm_id);
    return $self->new_other('RealmUser')->$method({
	realm_id => $bulletin_id,
	user_id => $user_id,
	role => $_MAIL_RECIPIENT,
    })
    && $self->new_other('UserRealmSubscription')->$method({
	realm_id => $bulletin_id,
	user_id => $user_id,
	is_subscribed => 1,
    });
}

1;
