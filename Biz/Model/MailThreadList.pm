# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::MailThreadList;
use strict;
use base 'Bivio::Biz::ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        primary_key => [[qw(RealmMail.realm_file_id RealmFile.realm_file_id)]],
	order_by => [qw(
            RealmFile.modified_date_time
	    RealmMail.from_email
	)],
	other => [
	    {
		name => 'part_list',
		type => $self->get_instance('MailPartList')->package_name,
		in_list => 1,
		constraint => 'NONE',
	    },
	],
	auth_id => [qw(RealmMail.realm_id RealmFile.realm_id)],
	parent_id => 'RealmMail.thread_root_id',
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    $row->{part_list} = $self->new_other('MailPartList')->load_all({
	parent_id => $row->{'RealmMail.realm_file_id'},
    });
    return 1;
}

1;
