# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ForumTreeListForm;
use strict;
use base 'Bivio::Biz::ListFormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_empty_row {
    my($self) = @_;
    $self->internal_put_field(mail_recipient => _mail_recipient($self));
    return;
}

sub execute_ok_row {
    my($self) = @_;
    return if _mail_recipient($self) eq $self->get('mail_recipient');
    my($method) = $self->get('mail_recipient') ? 'create' : 'unauth_delete';
    $self->new_other('RealmUser')->$method({
	realm_id => $self->get_list_model->get('Forum.forum_id'),
	user_id => $self->get_list_model->get_query->get('auth_id'),
	role => Bivio::Auth::Role->MAIL_RECIPIENT,
    });
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        list_class => 'ForumTreeList',
	visible => [
	    {
		name => 'mail_recipient',
		type => 'Boolean',
		constraint => 'NONE',
		in_list => 1,
	    },
	],
    });
}

sub is_program {
    my($self) = @_;
    return $self->get_list_model->get('Forum.parent_realm_id') == Bivio::Auth::RealmType->GENERAL->as_int ? 1 : 0;
}

sub _mail_recipient {
    return shift->get_list_model->get('mail_recipient');
}

1;
