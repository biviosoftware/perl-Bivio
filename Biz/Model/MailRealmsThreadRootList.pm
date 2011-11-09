# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::MailRealmsThreadRootList;
use strict;
use Bivio::Base 'Model.MailThreadRootList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_S) = b_use('Bivio.Search');
my($_MRW) = b_use('Type.MailReplyWho');

sub REALM_NAMES {
    return [];
}

sub drilldown_uri {
    my($self) = @_;
    my($req) = $self->req;
    return $req->format_uri({
	task_id => $req->get('task')->get_attr_as_id('thread_task'),
	realm => $self->get('RealmOwner.name'),
	query => $self->format_query('THIS_CHILD_LIST'),
    });
}

sub internal_initialize {
    my($self) = @_;
    my($info) = $self->SUPER::internal_initialize;
    delete($info->{auth_id});
    my($super_order_by) = delete($info->{order_by});
    return $self->merge_initialize_info($info, {
        version => 1,
	order_by => [
	    'RealmFile_2.modified_date_time',
	],
	other => [
	    @$super_order_by,
	    [qw(RealmMail.realm_id RealmOwner.realm_id)],
	    qw(
		RealmOwner.name
		RealmOwner.display_name
		RealmMail_2.from_display_name
		RealmMail_2.from_email
	    ),
	],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    return 0
	unless shift->SUPER::internal_post_load_row(@_);
    $row->{excerpt} = $_S->get_excerpt_for_primary_id(
	$row->{'RealmMail_2.realm_file_id'},
	$self->new_other('RealmFile'),
    );
    return 1;
}

sub internal_prepare_statement {
    my($self, $stmt, $query) = @_;
    $stmt->where(
	$stmt->IN('RealmOwner.name', $self->REALM_NAMES),
    );
    return;
}

sub reply_uri {
    my($self, $realm, $message_id) = @_;
    my($req) = $self->req;
    return $req->format_uri({
	task_id => $req->get('task')->get_attr_as_id('reply_task'),
	realm => $self->get('RealmOwner.name'),
	query => {
	    'ListQuery.this' => $self->get('RealmMail_2.realm_file_id'),
	    'to' => $_MRW->from_any('realm')->as_uri,
	},
    });
    return;
}

1;
