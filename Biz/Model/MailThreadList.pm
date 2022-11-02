# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::MailThreadList;
use strict;
use Bivio::Base 'Biz.ListModel';

my($_RM) = b_use('Model.RealmMail');

sub DATE_SORT_ORDER {
    return 1;
}

sub NOT_FOUND_IF_EMPTY {
    return 1;
}

sub get_mail_part_list {
    return shift->delegate_method($_RM, 'RealmMail.', @_);
}

sub get_message_anchor {
    my($self, $realm_file_id) = @_;
    return 'b_msg_' . ($realm_file_id || $self->get('RealmMail.realm_file_id'));
}

sub get_subject {
    my($self) = @_;
    $self->set_cursor_or_die(0)
        unless $self->has_cursor;
    return $self->get('RealmMail.subject');
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        can_iterate => 1,
        primary_key => [[qw(RealmMail.realm_file_id RealmFile.realm_file_id)]],
        order_by => [
            {
                name => 'RealmFile.modified_date_time',
                sort_order => $self->DATE_SORT_ORDER,
            },
            {
                name => 'RealmMail.realm_file_id',
                sort_order => $self->DATE_SORT_ORDER,
            },
            'RealmMail.from_email',
            'RealmMail.subject_lc',
        ],
        other => [
            'RealmMail.from_display_name',
            'RealmMail.subject',
            'RealmFile.path',
            'RealmFile.is_public',
            'RealmMail.message_id',
        ],
        auth_id => [qw(RealmMail.realm_id RealmFile.realm_id)],
        parent_id => 'RealmMail.thread_root_id',
    });
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    $stmt->where(['RealmFile.is_public', [1]])
        if $_RM->access_is_public_only($self->req);
    return shift->SUPER::internal_prepare_statement(@_);
}

1;
