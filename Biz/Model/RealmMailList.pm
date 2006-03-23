# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmMailList;
use strict;
use base 'Bivio::Biz::ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get_rfc822 {
    return shift->get_model('RealmFile')->get_content;
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
	)],
    });
}

1;
