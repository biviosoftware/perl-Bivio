# Copyright (c) 2006-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmMailList;
use strict;
use Bivio::Base 'Biz.ListModel';

my($_RM) = b_use('Model.RealmMail');
my($_MTL) = b_use('Model.MailThreadList');

sub get_rfc822 {
    return shift->get_model('RealmFile')->get_content;
}

sub get_mail_part_list {
    return shift->delegate_method($_RM, 'RealmMail.', @_);
}

sub get_message_anchor {
    return $_MTL->get_message_anchor(shift->get('RealmMail.realm_file_id'));
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        can_iterate => 1,
        primary_key => [[qw(RealmMail.realm_file_id RealmFile.realm_file_id)]],
        auth_id => [qw(RealmMail.realm_id RealmFile.realm_id)],
        order_by => [qw(
            RealmFile.modified_date_time
            RealmMail.subject_lc
            RealmMail.from_email
        )],
        other => [qw(
            RealmMail.subject
            RealmMail.thread_parent_id
            RealmMail.thread_root_id
            RealmFile.user_id
            RealmFile.is_public
        )],
    });
}

1;
