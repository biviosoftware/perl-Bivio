# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::MailUnsubscribeForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
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
	$rids = $self->new_other('RealmUser')
	    ->map_iterate(
		sub {
		    shift->get('realm_id');
		},
		'unauth_iterate_start',
		{
		    user_id => $uid,
		    role => $_MAIL_RECIPIENT,
		},
	    );
    }
    foreach my $rid (@$rids) {
	$self->req->with_realm(
	    $rid,
	    sub {
		my($role) = $_BMM->should_leave_realm($self->req) ? []
		    : [role => $_MAIL_RECIPIENT];
		$self->new_other('RealmUser')
		    ->delete_all({
			@$role,
			user_id => $uid,
		    });
		return;
	    },
	);
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
    my($self, $user_id, $realm_id) = @_;
    return $self->new_other('RealmUser')->unauth_rows_exist({
	realm_id => _bulletin_id($self, $realm_id), 
	user_id => $user_id,
    });
}

sub subscribe_to_bulletin_realm {
    my($self, $user_id, $realm_id) = @_;
    $self->new_other('RealmUser')->unauth_create_unless_exists({
	realm_id => _bulletin_id($self, $realm_id),
	user_id => $user_id,
	role => $_MAIL_RECIPIENT,
    });
    return;
}

sub unsubscribe_from_bulletin_realm {
    my($self, $user_id, $realm_id) = @_;
    $realm_id = _bulletin_id($self, $realm_id);
    $self->req
	->with_realm(
	    $realm_id,
	    sub {
		$self->new_other('RealmUser')
		    ->delete_all({user_id => $user_id});
		return;
	    },
	)
	if $_BMM->should_leave_realm($realm_id, $self->req);
    return;
}

sub _bulletin_id {
    my($self, $realm_id) = @_;
    return $realm_id
	|| b_use('FacadeComponent.Constant')
	->get_value('bulletin_realm_id', $self->req);
}

1;
