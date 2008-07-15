# Copyright (c) 2006-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::MailThreadList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RM) = __PACKAGE__->use('Model.RealmMail');

sub DATE_SORT_ORDER {
    return 1;
}

sub NOT_FOUND_IF_EMPTY {
    return 1;
}

sub get_mail_part_list {
    return shift->delegate_method($_RM, 'RealmMail.', @_);
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
	    'RealmMail.from_email',
            'RealmMail.subject_lc',
	],
	other => [
 	    [qw(RealmFile.user_id RealmOwner.realm_id)],
 	    'RealmOwner.display_name',
            'RealmMail.subject',
	    'RealmFile.path',
	],
	auth_id => [qw(RealmMail.realm_id RealmFile.realm_id)],
	parent_id => 'RealmMail.thread_root_id',
    });
}

1;
