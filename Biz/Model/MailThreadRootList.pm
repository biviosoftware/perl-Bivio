# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::MailThreadRootList;
use strict;
use Bivio::Base 'Model.MailThreadList';
my($_A) = __PACKAGE__->use('Mail.Address');
my($_P) = __PACKAGE__->use('Search.Parser');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub DATE_SORT_ORDER {
    return 0;
}

sub NOT_FOUND_IF_EMPTY {
    return 0;
}

sub drilldown_uri {
    my($self) = @_;
    my($req) = $self->req;
    return $req->format_uri({
	task_id => $req->get_nested(qw(task thread_task)),
	query => $self->format_query('THIS_CHILD_LIST'),
    });
}

sub internal_initialize {
    my($self) = @_;
    my($info) = $self->SUPER::internal_initialize;
    delete($info->{parent_id});
    return $self->merge_initialize_info($info, {
	order_by => [
	    {
		name => 'reply_count',
		type => 'Integer',
		in_select => 1,
		select_value => "(
                    SELECT COUNT(*) - 1
                    FROM realm_mail_t rm
                    WHERE rm.thread_root_id = realm_mail_t.thread_root_id
                 ) AS reply_count",
	    },
	],
	other => [
	    ['RealmMail.thread_parent_id', [undef]],
	    [qw(RealmMail.thread_root_id RealmMail_2.thread_root_id)],
	    [qw(RealmMail_2.realm_file_id RealmFile_2.realm_file_id)],
	    [qw(RealmMail.realm_id RealmFile_2.realm_id RealmMail_2.realm_id)],
	    [qw(RealmFile_2.user_id RealmOwner_2.realm_id)],
	    'RealmOwner_2.display_name',
	    {
		name => 'excerpt',
		type => 'Text',
		constraint => 'NONE',
	    },
	    {
		name => 'message_count',
		type => 'Integer',
		constraint => 'NONE',
	    },
	],
	where => [
	    'RealmMail_2.realm_file_id', '=', <<'EOF',
	    (
		SELECT MAX(rm.realm_file_id)
		FROM realm_mail_t rm
		WHERE rm.thread_root_id = realm_mail_t.thread_root_id
                AND rm.realm_id = realm_mail_t.realm_id
	    )
EOF
	],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    $row->{excerpt} = $_P->new_excerpt(
	$self->new_other('RealmFile')
	    ->load({realm_file_id => $row->{'RealmMail.realm_file_id'}}),
    )->get('excerpt');
    $row->{message_count} = $row->{reply_count} + 1;
    return 1;
}

1;
