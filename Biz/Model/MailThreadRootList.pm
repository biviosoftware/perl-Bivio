# Copyright (c) 2008-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::MailThreadRootList;
use strict;
use Bivio::Base 'Model.MailThreadList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_A) = b_use('Mail.Address');
my($_P) = b_use('Search.Parser');
my($_MF) = b_use('Model.MailForm');
my($_S) = b_use('Bivio.Search');

sub DATE_SORT_ORDER {
    return 0;
}

sub NOT_FOUND_IF_EMPTY {
    return 0;
}

sub AUTH_USER_ID_FIELD {
    return 'RealmFile_2.user_id';
}

sub drilldown_uri {
    my($self) = @_;
    my($req) = $self->req;
    return $req->format_uri({
	task_id => $req->get('task')->get_attr_as_id('thread_task'),
	query => $self->format_query('THIS_CHILD_LIST'),
    });
}

sub update_uri {
    my($self) = @_;
    my($req) = $self->req;
    return $req->format_uri({
	task_id => $req->get('task')->get_attr_as_id('update_task'),
	query => $_MF->reply_query('realm', $self),
    });
}

sub internal_initialize {
    my($self) = @_;
    my($info) = $self->SUPER::internal_initialize;
    delete($info->{parent_id});
    my($ii) = $self->merge_initialize_info($info, {
	order_by => [
	    {
		name => 'reply_count',
		type => 'Integer',
		in_select => 1,
		select_value => "(
                    SELECT COUNT(*) - 1
                    FROM realm_mail_t rm
                    WHERE rm.thread_root_id = realm_mail_t.thread_root_id
                    AND rm.realm_id = realm_mail_t.realm_id
                 ) AS reply_count",
	    },
	],
	other => [
	    ['RealmMail.thread_parent_id', [undef]],
	    [qw(RealmMail.thread_root_id RealmMail_2.thread_root_id)],
	    [qw(RealmMail_2.realm_file_id RealmFile_2.realm_file_id)],
	    [qw(RealmMail.realm_id RealmFile_2.realm_id RealmMail_2.realm_id)],
	    'RealmMail.from_display_name',
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
    # order list by most recent message or reply date
    unshift(@{$ii->{order_by}}, 'RealmFile_2.modified_date_time');
    return $ii;
}

sub internal_post_load_row {
    my($self, $row) = @_;
    $row->{excerpt} = $_S->get_excerpt_for_primary_id(
	$row->{'RealmMail.realm_file_id'},
	$self->new_other('RealmFile'),
    );
    $row->{message_count} = $row->{reply_count} + 1;
    return 1;
}

1;
